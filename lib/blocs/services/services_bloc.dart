import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/dio_client.dart';
import '../../core/utils/media_url.dart';
import '../../models/category_model.dart';
import '../../models/service_plan_model.dart';
import '../../services/categories_api_service.dart';
import '../../services/services_api_service.dart';

export '../../models/category_model.dart';
export '../../models/service_plan_model.dart';

part 'services_event.dart';
part 'services_state.dart';

// ignore: avoid_print
void _log(String msg) => print('[ServicesBloc] $msg');

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  ServicesBloc({
    ServicesApiService? servicesService,
    CategoriesApiService? categoriesService,
  })  : _servicesService =
            servicesService ?? ServicesApiService(dio: DioClient.instance.dio),
        _categoriesService =
            categoriesService ??
                CategoriesApiService(dio: DioClient.instance.dio),
        super(const ServicesInitial()) {
    on<ServicesLoaded>(_onLoaded);
    on<ServicesCategorySelected>(_onCategorySelected);
    on<ServicesSearchChanged>(_onSearchChanged);
    on<ServiceDetailRequested>(_onServiceDetailRequested);
    on<ServicePlanSelected>(_onPlanSelected);
  }

  final ServicesApiService _servicesService;
  final CategoriesApiService _categoriesService;

  // ── Initial load: categories + services in parallel ───────────────────────
  Future<void> _onLoaded(
    ServicesLoaded event,
    Emitter<ServicesState> emit,
  ) async {
    emit(const ServicesLoading());

    List<CategoryModel> categories = [];
    String? categoriesError;
    List<dynamic> rawServices = [];
    String? servicesError;

    await Future.wait([
      _categoriesService.getCategories().then((r) {
        categories = _parseCategories(r.data);
        _log('Loaded ${categories.length} categories');
      }).catchError((Object e) {
        _log('Categories error: $e');
        categoriesError = _errorMessage(e);
      }),

      _servicesService.getServices().then((r) {
        rawServices = _extractList(r.data);
        _log('Loaded ${rawServices.length} raw services');
      }).catchError((Object e) {
        _log('Services error: $e');
        servicesError = _errorMessage(e);
      }),
    ]);

    List<ServiceModel> services = [];
    try {
      services = _parseServices(rawServices, categories);
      _log('Parsed ${services.length} services');
    } catch (e, st) {
      _log('_parseServices threw: $e\n$st');
      servicesError ??= 'Failed to parse services response.';
    }

    emit(ServicesDataLoaded(
      categories: categories,
      categoriesError: categoriesError,
      services: services,
      filteredServices: services,
      selectedCategoryId: null,
      searchQuery: '',
      servicesLoading: false,
      servicesError: servicesError,
    ));
  }

  // ── Category selected: re-fetch services server-side ─────────────────────
  Future<void> _onCategorySelected(
    ServicesCategorySelected event,
    Emitter<ServicesState> emit,
  ) async {
    final current = state;
    if (current is! ServicesDataLoaded) return;

    emit(ServicesDataLoaded(
      categories: current.categories,
      categoriesError: current.categoriesError,
      services: const [],
      filteredServices: const [],
      selectedCategoryId: event.categoryId,
      searchQuery: current.searchQuery,
      servicesLoading: true,
      servicesError: null,
      detailServiceId: current.detailServiceId,
      detailLoading: current.detailLoading,
      detailError: current.detailError,
      detailPlans: current.detailPlans,
      selectedPlanId: current.selectedPlanId,
    ));

    try {
      final response = event.categoryId == null
          ? await _servicesService.getServices()
          : await _servicesService.getServicesByCategory(event.categoryId!);

      final raw = _extractList(response.data);
      final services = _parseServices(raw, current.categories);
      final filtered = _applySearch(services, current.searchQuery);

      emit(ServicesDataLoaded(
        categories: current.categories,
        categoriesError: current.categoriesError,
        services: services,
        filteredServices: filtered,
        selectedCategoryId: event.categoryId,
        searchQuery: current.searchQuery,
        servicesLoading: false,
        servicesError: null,
        detailServiceId: current.detailServiceId,
        detailLoading: current.detailLoading,
        detailError: current.detailError,
        detailPlans: current.detailPlans,
        selectedPlanId: current.selectedPlanId,
      ));
    } on DioException catch (e) {
      emit(ServicesDataLoaded(
        categories: current.categories,
        categoriesError: current.categoriesError,
        services: const [],
        filteredServices: const [],
        selectedCategoryId: event.categoryId,
        searchQuery: current.searchQuery,
        servicesLoading: false,
        servicesError: _dioError(e),
        detailServiceId: current.detailServiceId,
        detailLoading: current.detailLoading,
        detailError: current.detailError,
        detailPlans: current.detailPlans,
        selectedPlanId: current.selectedPlanId,
      ));
    } catch (e) {
      _log('_onCategorySelected unhandled: $e');
      emit(ServicesDataLoaded(
        categories: current.categories,
        categoriesError: current.categoriesError,
        services: const [],
        filteredServices: const [],
        selectedCategoryId: event.categoryId,
        searchQuery: current.searchQuery,
        servicesLoading: false,
        servicesError: 'Something went wrong. Please try again.',
        detailServiceId: current.detailServiceId,
        detailLoading: current.detailLoading,
        detailError: current.detailError,
        detailPlans: current.detailPlans,
        selectedPlanId: current.selectedPlanId,
      ));
    }
  }

  // ── Search: client-side filter ────────────────────────────────────────────
  void _onSearchChanged(
    ServicesSearchChanged event,
    Emitter<ServicesState> emit,
  ) {
    final current = state;
    if (current is! ServicesDataLoaded || current.servicesLoading) return;

    emit(ServicesDataLoaded(
      categories: current.categories,
      categoriesError: current.categoriesError,
      services: current.services,
      filteredServices: _applySearch(current.services, event.query),
      selectedCategoryId: current.selectedCategoryId,
      searchQuery: event.query,
      servicesLoading: false,
      servicesError: current.servicesError,
      detailServiceId: current.detailServiceId,
      detailLoading: current.detailLoading,
      detailError: current.detailError,
      detailPlans: current.detailPlans,
      selectedPlanId: current.selectedPlanId,
    ));
  }

  // ── Service detail ────────────────────────────────────────────────────────
  //
  // Confirmed response shape from GET /api/services/{id}:
  //   { "success": true, "message": "...", "data": { ...service fields... } }
  //
  // TODO(backend): plans are not yet included in this response.
  //   To enable plan selection, add a "plans" array inside "data":
  //   "data": {
  //     "id": 3, "name": "Spotify", ...,
  //     "plans": [
  //       { "id": 1, "service_id": 3, "plan_name": "Individual",
  //         "billing_cycle": "monthly", "price": "9.99", "features": "..." },
  //       ...
  //     ]
  //   }
  Future<void> _onServiceDetailRequested(
    ServiceDetailRequested event,
    Emitter<ServicesState> emit,
  ) async {
    if (state is! ServicesDataLoaded) return;

    final id = int.tryParse(event.serviceId);
    if (id == null) {
      _emitDetailResult(emit, event.serviceId, const [], 'Invalid service ID.');
      return;
    }

    _emitDetailLoading(emit, event.serviceId);

    var plans = const <ServicePlan>[];
    String? detailError;

    try {
      final response = await _servicesService.getServiceById(id);
      _log('ServiceDetail id=$id  status=${response.statusCode}');

      plans = _parsePlansFromDetail(response.data);
      _log('ServiceDetail id=$id  plans=${plans.length}');
    } on DioException catch (e) {
      _log('ServiceDetail DioException: ${_dioError(e)}');
      detailError = _dioError(e);
    } catch (e) {
      _log('ServiceDetail error: $e');
      detailError = 'Failed to load service details.';
    }

    _emitDetailResult(emit, event.serviceId, plans, detailError);
  }

  void _emitDetailLoading(Emitter<ServicesState> emit, String serviceId) {
    final s = state;
    if (s is! ServicesDataLoaded) return;
    emit(s.copyWith(
      detailServiceId: serviceId,
      detailLoading: true,
      detailError: null,
      detailPlans: const [],
      selectedPlanId: null,
    ));
  }

  void _emitDetailResult(
    Emitter<ServicesState> emit,
    String serviceId,
    List<ServicePlan> plans,
    String? error,
  ) {
    final s = state;
    if (s is! ServicesDataLoaded) return;
    emit(s.copyWith(
      detailServiceId: serviceId,
      detailLoading: false,
      detailError: error,
      detailPlans: plans,
    ));
  }

  // ── Plan selection ────────────────────────────────────────────────────────
  Future<void> _onPlanSelected(
    ServicePlanSelected event,
    Emitter<ServicesState> emit,
  ) async {
    final current = state;
    if (current is! ServicesDataLoaded) return;
    emit(current.copyWith(selectedPlanId: event.planId));
  }

  // ── Plan parsing ──────────────────────────────────────────────────────────

  // Backend DB has service_plans rows, but GET /api/services/{id} does not
  // yet include them in its response.
  // Required backend fix: add "plans" inside the "data" object:
  //   "data": { "id": 3, ..., "plans": [
  //     { "id": 1, "service_id": 3, "plan_name": "Individual",
  //       "billing_cycle": "monthly", "price": "9.99", "features": "..." }
  //   ]}
  List<ServicePlan> _parsePlansFromDetail(dynamic body) {
    if (body is! Map) return [];
    final top = _toStringMap(body);

    // Unwrap { "success": true, "data": { ... } } envelope.
    final service = top['data'] is Map
        ? _toStringMap(top['data'] as Map)
        : top;

    // Check data["plans"] and data["service_plans"] only — no guessing.
    final raw = service['plans'] ?? service['service_plans'];
    if (raw is! List || raw.isEmpty) return [];

    final result = <ServicePlan>[];
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        result.add(ServicePlan.fromJson(_toStringMap(item)));
      } catch (e) {
        _log('Plan parse error: $e  item=$item');
      }
    }
    return result;
  }

  // ── List / category / search parsing ─────────────────────────────────────

  List<CategoryModel> _parseCategories(dynamic data) {
    final result = <CategoryModel>[];
    for (final item in _extractList(data)) {
      if (item is! Map) continue;
      try {
        result.add(CategoryModel.fromJson(_toStringMap(item)));
      } catch (e) {
        _log('Category parse error: $e');
      }
    }
    return result;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in const [
        'data', 'payload', 'services', 'results', 'items', 'records'
      ]) {
        final val = data[key];
        // Direct array: { "data": [...] }
        if (val is List) return val;
        // Laravel pagination: { "data": { "current_page": 1, "data": [...] } }
        if (val is Map) {
          for (final inner in const [
            'data', 'items', 'records', 'results'
          ]) {
            if (val[inner] is List) return val[inner] as List;
          }
        }
      }
    }
    return [];
  }

  List<ServiceModel> _parseServices(
    List<dynamic> raw,
    List<CategoryModel> categories,
  ) {
    final result = <ServiceModel>[];
    for (final item in raw) {
      if (item == null) continue;
      try {
        final map = item is Map<String, dynamic>
            ? item
            : _toStringMap(item as Map);
        var svc = ServiceModel.fromJson(map);
        if (svc.category.isEmpty && svc.categoryId != null) {
          final cat =
              categories.where((c) => c.id == svc.categoryId).firstOrNull;
          if (cat != null) {
            svc = svc.copyWith(
              category: cat.name,
              color: ServiceModel._colorFor(cat.name),
            );
          }
        }
        result.add(svc);
      } catch (e) {
        _log('Service parse error: $e');
      }
    }
    return result;
  }

  List<ServiceModel> _applySearch(List<ServiceModel> services, String query) {
    if (query.isEmpty) return services;
    final q = query.toLowerCase();
    return services
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.category.toLowerCase().contains(q) ||
            s.description.toLowerCase().contains(q))
        .toList();
  }

  Map<String, dynamic> _toStringMap(Map m) =>
      m.map((k, v) => MapEntry(k.toString(), v));

  // ── Error helpers ─────────────────────────────────────────────────────────

  String _errorMessage(Object e) =>
      e is DioException ? _dioError(e) : 'Something went wrong.';

  String _dioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (e.response == null) {
          return 'Network error. Please check your connection.';
        }
        break;
      case DioExceptionType.badCertificate:
        return 'Secure connection failed.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.badResponse:
        break;
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return 'Session expired. Please log in again.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server error. Please try again later.';
    }
    final data = e.response?.data;
    if (data is Map) return data['message'] as String? ?? 'Something went wrong.';
    return 'Failed to load. Please try again.';
  }
}
