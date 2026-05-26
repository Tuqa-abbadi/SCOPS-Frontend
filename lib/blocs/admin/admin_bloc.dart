import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/dio_client.dart';
import '../../services/admin_api_service.dart';

part 'admin_event.dart';
part 'admin_state.dart';

// ignore: avoid_print
void _log(String msg) => print('[AdminBloc] $msg');

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc({AdminApiService? adminApiService})
      : _api = adminApiService ??
            AdminApiService(dio: DioClient.instance.dio),
        super(const AdminInitial()) {
    on<AdminLoaded>(_onLoaded);
    on<AdminRefreshRequested>(_onRefresh);
    on<AdminUserCreateRequested>(_onUserCreate);
    on<AdminUserUpdateRequested>(_onUserUpdate);
    on<AdminUserDeleteRequested>(_onUserDelete);
    on<AdminUserToggleRequested>(_onUserToggle);
    on<AdminUserPasswordResetRequested>(_onPasswordReset);
    on<AdminUserSubscriptionsRequested>(_onUserSubscriptions);
    on<AdminServiceCreateRequested>(_onServiceCreate);
    on<AdminServiceUpdateRequested>(_onServiceUpdate);
    on<AdminServiceDeleteRequested>(_onServiceDelete);
    on<AdminActionErrorCleared>(_onErrorCleared);
  }

  final AdminApiService _api;

  // ── Initial load ───────────────────────────────────────────────────────────

  Future<void> _onLoaded(AdminLoaded _, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    await _loadAll(emit);
  }

  Future<void> _onRefresh(
    AdminRefreshRequested _,
    Emitter<AdminState> emit,
  ) async {
    final cur = state;
    if (cur is AdminData) {
      emit(cur.copyWith(isActionLoading: true, clearError: true, clearSuccess: true));
    } else {
      emit(const AdminLoading());
    }
    await _loadAll(emit);
  }

  Future<void> _loadAll(Emitter<AdminState> emit) async {
    AdminStatisticsModel? stats;
    List<AdminUserModel> users = [];
    List<AdminServiceModel> services = [];
    String? loadError;

    await Future.wait([
      _api.getStatistics().then((r) {
        stats = AdminStatisticsModel.fromJson(_extractData(r.data));
        _log('Statistics loaded');
      }).catchError((Object e) {
        _log('Statistics error: $e');
      }),
      _api.getUsers().then((r) {
        users = _parseUsers(_extractList(r.data));
        _log('Users loaded: ${users.length}');
      }).catchError((Object e) {
        _log('Users error: $e');
        loadError ??= _msgFor(e);
      }),
      _api.getServices().then((r) {
        services = _parseServices(_extractList(r.data));
        _log('Services loaded: ${services.length}');
      }).catchError((Object e) {
        _log('Services error: $e');
        loadError ??= _msgFor(e);
      }),
    ]);

    if (loadError != null && users.isEmpty && services.isEmpty && stats == null) {
      emit(AdminError(message: loadError!));
    } else {
      final prev = state is AdminData ? state as AdminData : null;
      emit(AdminData(
        statistics: stats,
        users: users,
        services: services,
        // Preserve subscription view across refresh
        viewingUserId: prev?.viewingUserId,
        viewingUserSubscriptions: prev?.viewingUserSubscriptions ?? [],
      ));
    }
  }

  // ── User actions ───────────────────────────────────────────────────────────

  Future<void> _onUserCreate(
    AdminUserCreateRequested event,
    Emitter<AdminState> emit,
  ) async {
    if (!_requireData(emit)) return;
    _emitActionLoading(emit);
    try {
      await _api.createUser(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        role: event.role,
        phone: event.phone,
      );
      _log('User created');
      await _refreshUsers(emit, success: 'User created successfully.');
    } on DioException catch (e) {
      _emitActionError(emit, _dioError(e));
    } catch (e) {
      _emitActionError(emit, 'Failed to create user. Please try again.');
    }
  }

  Future<void> _onUserUpdate(
    AdminUserUpdateRequested event,
    Emitter<AdminState> emit,
  ) async {
    if (!_requireData(emit)) return;
    _emitActionLoading(emit);
    try {
      await _api.updateUser(
        event.id,
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        role: event.role,
        phone: event.phone,
      );
      _log('User updated: ${event.id}');
      await _refreshUsers(emit, success: 'User updated successfully.');
    } on DioException catch (e) {
      _emitActionError(emit, _dioError(e));
    } catch (e) {
      _emitActionError(emit, 'Failed to update user. Please try again.');
    }
  }

  Future<void> _onUserDelete(
    AdminUserDeleteRequested event,
    Emitter<AdminState> emit,
  ) async {
    if (!_requireData(emit)) return;
    _emitActionLoading(emit);
    try {
      await _api.deleteUser(event.id);
      _log('User deleted: ${event.id}');
      await _refreshUsers(emit, success: 'User deleted.');
    } on DioException catch (e) {
      _emitActionError(emit, _dioError(e));
    } catch (e) {
      _emitActionError(emit, 'Failed to delete user. Please try again.');
    }
  }

  Future<void> _onUserToggle(
    AdminUserToggleRequested event,
    Emitter<AdminState> emit,
  ) async {
    if (!_requireData(emit)) return;
    _emitActionLoading(emit);
    try {
      await _api.toggleUser(event.id);
      _log('User toggled: ${event.id}');
      await _refreshUsers(emit, success: 'User status updated.');
    } on DioException catch (e) {
      _emitActionError(emit, _dioError(e));
    } catch (e) {
      _emitActionError(emit, 'Failed to update user status.');
    }
  }

  Future<void> _onPasswordReset(
    AdminUserPasswordResetRequested event,
    Emitter<AdminState> emit,
  ) async {
    if (!_requireData(emit)) return;
    _emitActionLoading(emit);
    try {
      await _api.resetUserPassword(event.id, event.newPassword);
      _log('Password reset: ${event.id}');
      final cur = state as AdminData?;
      if (cur != null) {
        emit(cur.copyWith(isActionLoading: false, actionSuccess: 'Password reset successfully.'));
      }
    } on DioException catch (e) {
      _emitActionError(emit, _dioError(e));
    } catch (e) {
      _emitActionError(emit, 'Failed to reset password. Please try again.');
    }
  }

  Future<void> _onUserSubscriptions(
    AdminUserSubscriptionsRequested event,
    Emitter<AdminState> emit,
  ) async {
    final cur = state as AdminData?;
    if (cur == null) return;
    emit(cur.copyWith(
      viewingUserId: event.userId,
      subscriptionsLoading: true,
      viewingUserSubscriptions: [],
    ));
    try {
      final r = await _api.getUserSubscriptions(event.userId);
      final subs = _extractList(r.data)
          .whereType<Map>()
          .map((m) => AdminUserSubscriptionModel.fromJson(
                m.map((k, v) => MapEntry(k.toString(), v)),
              ))
          .toList();
      final c = state as AdminData?;
      if (c != null) {
        emit(c.copyWith(subscriptionsLoading: false, viewingUserSubscriptions: subs));
      }
    } on DioException catch (e) {
      _log('User subs error: $e');
      final c = state as AdminData?;
      if (c != null) {
        emit(c.copyWith(subscriptionsLoading: false, actionError: _dioError(e)));
      }
    } catch (e) {
      _log('User subs error: $e');
      final c = state as AdminData?;
      if (c != null) {
        emit(c.copyWith(subscriptionsLoading: false, actionError: 'Failed to load subscriptions.'));
      }
    }
  }

  // ── Service actions ────────────────────────────────────────────────────────

  Future<void> _onServiceCreate(
    AdminServiceCreateRequested event,
    Emitter<AdminState> emit,
  ) async {
    if (!_requireData(emit)) return;
    _emitActionLoading(emit);
    try {
      await _api.createService(
        name: event.name,
        defaultAmount: event.defaultAmount,
        billingCycle: event.billingCycle,
        description: event.description,
        categoryId: event.categoryId,
        logoUrl: event.logoUrl,
      );
      _log('Service created: ${event.name}');
      await _refreshServices(emit, success: 'Service created successfully.');
    } on DioException catch (e) {
      _emitActionError(emit, _dioError(e));
    } catch (e) {
      _emitActionError(emit, 'Failed to create service. Please try again.');
    }
  }

  Future<void> _onServiceUpdate(
    AdminServiceUpdateRequested event,
    Emitter<AdminState> emit,
  ) async {
    if (!_requireData(emit)) return;
    _emitActionLoading(emit);
    try {
      await _api.updateService(
        event.id,
        name: event.name,
        defaultAmount: event.defaultAmount,
        billingCycle: event.billingCycle,
        description: event.description,
        categoryId: event.categoryId,
        logoUrl: event.logoUrl,
      );
      _log('Service updated: ${event.id}');
      await _refreshServices(emit, success: 'Service updated successfully.');
    } on DioException catch (e) {
      _emitActionError(emit, _dioError(e));
    } catch (e) {
      _emitActionError(emit, 'Failed to update service. Please try again.');
    }
  }

  Future<void> _onServiceDelete(
    AdminServiceDeleteRequested event,
    Emitter<AdminState> emit,
  ) async {
    if (!_requireData(emit)) return;
    _emitActionLoading(emit);
    try {
      await _api.deleteService(event.id);
      _log('Service deleted: ${event.id}');
      await _refreshServices(emit, success: 'Service deleted.');
    } on DioException catch (e) {
      _emitActionError(emit, _dioError(e));
    } catch (e) {
      _emitActionError(emit, 'Failed to delete service. Please try again.');
    }
  }

  void _onErrorCleared(AdminActionErrorCleared _, Emitter<AdminState> emit) {
    final cur = state as AdminData?;
    if (cur != null) {
      emit(cur.copyWith(clearError: true, clearSuccess: true));
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  bool _requireData(Emitter<AdminState> emit) => state is AdminData;

  void _emitActionLoading(Emitter<AdminState> emit) {
    final cur = state as AdminData?;
    if (cur != null) {
      emit(cur.copyWith(isActionLoading: true, clearError: true, clearSuccess: true));
    }
  }

  void _emitActionError(Emitter<AdminState> emit, String message) {
    final cur = state as AdminData?;
    if (cur != null) {
      emit(cur.copyWith(isActionLoading: false, actionError: message));
    }
  }

  Future<void> _refreshUsers(
    Emitter<AdminState> emit, {
    String? success,
  }) async {
    try {
      final r = await _api.getUsers();
      final users = _parseUsers(_extractList(r.data));
      final cur = state as AdminData?;
      if (cur != null) {
        emit(cur.copyWith(users: users, isActionLoading: false, actionSuccess: success));
      }
    } catch (e) {
      _emitActionError(emit, 'Action done but failed to refresh users.');
    }
  }

  Future<void> _refreshServices(
    Emitter<AdminState> emit, {
    String? success,
  }) async {
    try {
      final r = await _api.getServices();
      final services = _parseServices(_extractList(r.data));
      final cur = state as AdminData?;
      if (cur != null) {
        emit(cur.copyWith(services: services, isActionLoading: false, actionSuccess: success));
      }
    } catch (e) {
      _emitActionError(emit, 'Action done but failed to refresh services.');
    }
  }

  List<AdminUserModel> _parseUsers(List<dynamic> raw) => raw
      .whereType<Map>()
      .map((m) {
        final mapped = m.map((k, v) => MapEntry(k.toString(), v));
        _log('User fields: ${mapped.keys.toList()} | id=${mapped['id']} | user_id=${mapped['user_id']} | uuid=${mapped['uuid']}');
        return AdminUserModel.fromJson(mapped);
      })
      .toList();

  List<AdminServiceModel> _parseServices(List<dynamic> raw) => raw
      .whereType<Map>()
      .map((m) => AdminServiceModel.fromJson(m.map((k, v) => MapEntry(k.toString(), v))))
      .toList();

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in const [
        'data', 'users', 'services', 'subscriptions',
        'payload', 'results', 'items', 'records',
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

  Map<String, dynamic> _extractData(dynamic data) {
    if (data is Map) {
      final m = data.map((k, v) => MapEntry(k.toString(), v));
      final nested = m['data'];
      if (nested is Map) return nested.map((k, v) => MapEntry(k.toString(), v));
      return m;
    }
    return {};
  }

  String _msgFor(Object e) => e is DioException ? _dioError(e) : e.toString();

  String _dioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (e.response == null) return 'Network error. Please check your connection.';
        break;
      case DioExceptionType.badCertificate:
        return 'Secure connection failed.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.badResponse:
        break;
    }
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) return 'Session expired. Please log in again.';
    final body = e.response?.data;
    final serverMsg = body is Map
        ? (body['message'] as String? ?? body['error'] as String?)
        : null;
    if (status != null && status >= 500) {
      _log('Server error $status body: $body');
      return serverMsg ?? 'Server error. Please try again later.';
    }
    if (serverMsg != null) return serverMsg;
    return 'Something went wrong. Please try again.';
  }
}
