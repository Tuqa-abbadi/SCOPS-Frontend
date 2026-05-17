import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/network/dio_client.dart';
import '../../models/subscription_model.dart';
import '../../services/subscriptions_api_service.dart';
import '../../services/services_api_service.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

// ignore: avoid_print
void _log(String msg) => print('[SubscriptionBloc] $msg');

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc({
    SubscriptionsApiService? subscriptionsService,
    ServicesApiService? servicesService,
  })  : _subscriptionsService = subscriptionsService ??
            SubscriptionsApiService(dio: DioClient.instance.dio),
        _servicesService =
            servicesService ?? ServicesApiService(dio: DioClient.instance.dio),
        super(const SubscriptionInitial()) {
    on<SubscriptionLoaded>(_onLoaded);
    on<SubscriptionsRefreshRequested>(_onRefresh);
    on<SubscriptionAdded>(_onAdded);
    on<SubscriptionUpdated>(_onUpdated);
    on<SubscriptionCancelled>(_onCancelled);
    on<SubscriptionDeleted>(_onDeleted);
    on<SubscriptionCancelRequested>(_onCancelRequested);
    on<SubscriptionPauseRequested>(_onPauseRequested);
    on<SubscriptionResumeRequested>(_onResumeRequested);
  }

  final SubscriptionsApiService _subscriptionsService;
  final ServicesApiService _servicesService;

  // serviceId → (name, icon emoji)
  final Map<int, (String, String)> _serviceCache = {};

  // ── Initial load ───────────────────────────────────────────────────────────

  Future<void> _onLoaded(
    SubscriptionLoaded _,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionsLoading());
    await _fetchAndEmit(emit, previous: const []);
  }

  Future<void> _onRefresh(
    SubscriptionsRefreshRequested _,
    Emitter<SubscriptionState> emit,
  ) async {
    final current = state;
    final prev = current is SubscriptionData
        ? current.subscriptions
        : <SubscriptionModel>[];
    if (current is SubscriptionData) {
      emit(current.copyWith(isLoading: true, clearError: true));
    }
    await _fetchAndEmit(emit, previous: prev);
  }

  Future<void> _fetchAndEmit(
    Emitter<SubscriptionState> emit, {
    required List<SubscriptionModel> previous,
  }) async {
    try {
      await _ensureServiceCache();
      final response = await _subscriptionsService.getSubscriptions();
      final raw = _extractList(response.data);
      final List<SubscriptionModel> subs = raw
          .map(_toDisplayModel)
          .whereType<SubscriptionModel>()
          .toList();
      emit(SubscriptionData(subscriptions: subs));
    } on DioException catch (e) {
      _log('Load error: $e');
      final msg = _dioError(e);
      if (previous.isEmpty) {
        emit(SubscriptionError(message: msg, previous: previous));
      } else {
        emit(SubscriptionData(subscriptions: previous, actionError: msg));
      }
    } catch (e) {
      _log('Unexpected load error: $e');
      if (previous.isEmpty) {
        emit(const SubscriptionError(
            message: 'Failed to load subscriptions. Please try again.'));
      } else {
        emit(SubscriptionData(
            subscriptions: previous, actionError: 'Failed to refresh.'));
      }
    }
  }

  // ── Create (SubscriptionAdded) ─────────────────────────────────────────────

  Future<void> _onAdded(
    SubscriptionAdded event,
    Emitter<SubscriptionState> emit,
  ) async {
    final current =
        state is SubscriptionData ? state as SubscriptionData : null;

    // If we have no service_id we cannot POST to the API.
    // Gracefully store locally so the UI keeps working.
    if (event.serviceId == null || event.serviceId == 0) {
      _log('SubscriptionAdded: no serviceId – storing locally');
      final sub = SubscriptionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        apiId: DateTime.now().millisecondsSinceEpoch,
        serviceId: 0,
        serviceName: event.serviceName,
        serviceIcon: event.serviceIcon,
        plan: event.plan,
        billingCycle: _capitalizeCycle(event.billingCycle),
        amount: event.amount,
        nextRenewal: event.nextRenewal,
        cardId: event.cardId,
        reminderDays: event.reminderDays,
        priority: event.priority,
      );
      final List<SubscriptionModel> subs = [...(current?.subscriptions ?? []), sub];
      emit(SubscriptionData(subscriptions: subs));
      return;
    }

    try {
      if (current != null) emit(current.copyWith(isLoading: true));

      final billingCycleLower = event.billingCycle.toLowerCase();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final renewal = _calcRenewalDateStr(billingCycleLower);

      await _subscriptionsService.createSubscription(
        serviceId: event.serviceId!,
        planId: event.planId,
        cardId: event.cardApiId,
        amount: event.amount,
        billingCycle: billingCycleLower,
        startDate: today,
        renewalDate: renewal,
        reminderDays: event.reminderDays,
        priority: event.priority,
      );

      // Cache service name/icon for future display
      _serviceCache[event.serviceId!] = (event.serviceName, event.serviceIcon);

      await _fetchAndEmit(
          emit, previous: current?.subscriptions ?? []);
    } on DioException catch (e) {
      _log('Create error (Dio): $e');
      final msg = _dioError(e);
      if (current != null) {
        emit(current.copyWith(isLoading: false, actionError: msg));
      } else {
        emit(SubscriptionError(message: msg));
      }
    } catch (e) {
      _log('Create error (other): $e');
      if (current != null) {
        emit(current.copyWith(
            isLoading: false,
            actionError: 'Failed to add subscription. Please try again.'));
      }
    }
  }

  // ── Local edit (no PUT endpoint yet) ──────────────────────────────────────

  void _onUpdated(
    SubscriptionUpdated event,
    Emitter<SubscriptionState> emit,
  ) {
    final current = state;
    if (current is! SubscriptionData) return;
    final List<SubscriptionModel> updated = current.subscriptions.map((s) {
      if (s.id != event.id) return s;
      return s.copyWith(
        plan: event.plan,
        billingCycle: event.billingCycle,
        amount: event.amount,
        cardId: event.cardId,
        reminderDays: event.reminderDays,
        nextRenewal: event.nextRenewal,
      );
    }).toList();
    emit(SubscriptionData(subscriptions: updated));
  }

  // ── Legacy SubscriptionCancelled → maps to API cancel ─────────────────────

  Future<void> _onCancelled(
    SubscriptionCancelled event,
    Emitter<SubscriptionState> emit,
  ) async {
    final apiId = int.tryParse(event.id);
    if (apiId != null && apiId > 0) {
      await _performAction(
          apiId, emit, _subscriptionsService.cancelSubscription);
    }
  }

  // ── Local delete (removes from list without API call) ─────────────────────

  void _onDeleted(SubscriptionDeleted event, Emitter<SubscriptionState> emit) {
    final current = state;
    if (current is! SubscriptionData) return;
    final List<SubscriptionModel> remaining =
        current.subscriptions.where((s) => s.id != event.id).toList();
    emit(SubscriptionData(subscriptions: remaining));
  }

  // ── API actions ────────────────────────────────────────────────────────────

  Future<void> _onCancelRequested(
    SubscriptionCancelRequested event,
    Emitter<SubscriptionState> emit,
  ) async =>
      _performAction(
          event.id, emit, _subscriptionsService.cancelSubscription);

  Future<void> _onPauseRequested(
    SubscriptionPauseRequested event,
    Emitter<SubscriptionState> emit,
  ) async =>
      _performAction(
          event.id, emit, _subscriptionsService.pauseSubscription);

  Future<void> _onResumeRequested(
    SubscriptionResumeRequested event,
    Emitter<SubscriptionState> emit,
  ) async =>
      _performAction(
          event.id, emit, _subscriptionsService.resumeSubscription);

  Future<void> _performAction(
    int id,
    Emitter<SubscriptionState> emit,
    Future<dynamic> Function(int) action,
  ) async {
    final current =
        state is SubscriptionData ? state as SubscriptionData : null;
    try {
      if (current != null) emit(current.copyWith(isLoading: true));
      await action(id);
      await _fetchAndEmit(emit, previous: current?.subscriptions ?? []);
    } on DioException catch (e) {
      _log('Action error (Dio): $e');
      final msg = _dioError(e);
      if (current != null) {
        emit(current.copyWith(isLoading: false, actionError: msg));
      }
    } catch (e) {
      _log('Action error (other): $e');
      if (current != null) {
        emit(current.copyWith(
            isLoading: false, actionError: 'Action failed. Please try again.'));
      }
    }
  }

  // ── Service name cache ─────────────────────────────────────────────────────

  Future<void> _ensureServiceCache() async {
    if (_serviceCache.isNotEmpty) return;
    try {
      final response = await _servicesService.getServices();
      final list = _extractList(response.data);
      for (final item in list) {
        if (item is! Map) continue;
        final map = item.map((k, v) => MapEntry(k.toString(), v));
        final id = _parseInt(map['id'] ?? map['service_id']);
        final name = map['name'] as String? ?? '';
        final icon = map['icon'] as String? ?? _iconForName(name);
        if (id != null && name.isNotEmpty) {
          _serviceCache[id] = (name, icon);
        }
      }
      _log('Service cache: ${_serviceCache.length} entries');
    } catch (e) {
      _log('Service cache failed (non-fatal): $e');
    }
  }

  // ── Model conversion ───────────────────────────────────────────────────────

  SubscriptionModel? _toDisplayModel(dynamic raw) {
    try {
      if (raw is! Map) return null;
      final json = raw.map((k, v) => MapEntry(k.toString(), v));
      final api = SubscriptionApiModel.fromJson(json);

      final cached = _serviceCache[api.serviceId];
      final serviceName = cached?.$1 ?? 'Service #${api.serviceId}';
      final serviceIcon = cached?.$2 ?? _iconForName('');

      final billingCycle = _capitalizeCycle(api.billingCycle);
      final plan = api.planId != null ? 'Plan #${api.planId}' : billingCycle;

      return SubscriptionModel(
        id: api.id.toString(),
        apiId: api.id,
        serviceId: api.serviceId,
        planId: api.planId,
        cardApiId: api.cardId,
        serviceName: serviceName,
        serviceIcon: serviceIcon,
        plan: plan,
        billingCycle: billingCycle,
        amount: api.amount,
        nextRenewal: api.renewalDate,
        cardId: api.cardId?.toString() ?? '',
        reminderDays: api.reminderDays,
        status: _parseStatus(api.status),
        priority: api.priority,
      );
    } catch (e) {
      _log('Model conversion error: $e');
      return null;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in const [
        'data',
        'subscriptions',
        'payload',
        'results',
        'items'
      ]) {
        final val = data[key];
        if (val is List) return val;
        if (val is Map) {
          for (final inner in const ['data', 'items', 'results']) {
            if (val[inner] is List) return val[inner] as List;
          }
        }
      }
    }
    return [];
  }

  int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  SubscriptionStatus _parseStatus(String s) {
    switch (s.toLowerCase()) {
      case 'cancelled':
      case 'canceled':
        return SubscriptionStatus.cancelled;
      case 'paused':
        return SubscriptionStatus.paused;
      default:
        return SubscriptionStatus.active;
    }
  }

  String _capitalizeCycle(String cycle) {
    switch (cycle.toLowerCase()) {
      case 'weekly':
        return 'Weekly';
      case 'yearly':
        return 'Yearly';
      default:
        return 'Monthly';
    }
  }

  String _calcRenewalDateStr(String billingCycle) {
    final now = DateTime.now();
    final DateTime renewal;
    switch (billingCycle) {
      case 'weekly':
        renewal = now.add(const Duration(days: 7));
        break;
      case 'yearly':
        renewal = now.add(const Duration(days: 365));
        break;
      default:
        renewal = now.add(const Duration(days: 30));
    }
    return DateFormat('yyyy-MM-dd').format(renewal);
  }

  String _iconForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('netflix') || n.contains('disney') || n.contains('hulu')) {
      return '🎬';
    }
    if (n.contains('spotify') || n.contains('music') || n.contains('tidal')) {
      return '🎵';
    }
    if (n.contains('adobe') || n.contains('figma') || n.contains('design')) {
      return '🎨';
    }
    if (n.contains('github') || n.contains('aws') || n.contains('cloud')) {
      return '☁️';
    }
    if (n.contains('office') || n.contains('notion') || n.contains('slack')) {
      return '💼';
    }
    if (n.contains('ai') || n.contains('openai') || n.contains('claude')) {
      return '🤖';
    }
    if (n.contains('youtube')) return '▶️';
    if (n.contains('game') || n.contains('xbox') || n.contains('play')) {
      return '🎮';
    }
    return '📦';
  }

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
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) {
      return 'Session expired. Please log in again.';
    }
    if (status != null && status >= 500) {
      return 'Server error. Please try again later.';
    }
    final data = e.response?.data;
    if (data is Map) return data['message'] as String? ?? 'Something went wrong.';
    return 'Something went wrong. Please try again.';
  }
}
