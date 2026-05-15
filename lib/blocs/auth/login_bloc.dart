import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class LoginBloc extends Bloc<AuthEvent, AuthState> {
  LoginBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<TogglePasswordVisibility>(_onTogglePassword);
  }

  final AuthRepository _authRepository;

  void _onTogglePassword(
    TogglePasswordVisibility event,
    Emitter<AuthState> emit,
  ) {
    final current = state is LoginState ? state as LoginState : const LoginState();
    emit(current.copyWith(showPassword: !current.showPassword));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current = state is LoginState ? state as LoginState : const LoginState();
    final email = event.email.trim();

    if (email.isEmpty && event.password.isEmpty) {
      emit(
        current.copyWith(
          errorMessage: 'Please enter your email and password.',
        ),
      );
      return;
    }
    if (email.isEmpty) {
      emit(current.copyWith(errorMessage: 'Please enter your email.'));
      return;
    }
    if (event.password.isEmpty) {
      emit(current.copyWith(errorMessage: 'Please enter your password.'));
      return;
    }

    emit(current.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.login(
      email: email,
      password: event.password,
    );

    if (result.success) {
      final userMap = result.user;
      final user = userMap != null ? UserModel.fromMap(userMap) : null;
      emit(LoginSuccess(user: user));
    } else {
      emit(
        current.copyWith(
          isLoading: false,
          errorMessage: result.message,
        ),
      );
    }
  }
}
