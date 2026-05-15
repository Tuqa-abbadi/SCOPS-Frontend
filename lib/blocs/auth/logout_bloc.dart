import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class LogoutBloc extends Bloc<AuthEvent, AuthState> {
  LogoutBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<LogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const LogoutInProgress());
    // Repository always clears local tokens even if the API call fails.
    await _authRepository.logout();
    emit(const LogoutSuccess());
  }
}
