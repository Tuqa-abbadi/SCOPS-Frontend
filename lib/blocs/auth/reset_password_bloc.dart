import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class ResetPasswordBloc extends Bloc<AuthEvent, AuthState> {
  ResetPasswordBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const ResetPasswordState()) {
    on<VerifyCodeSubmitted>(_onVerifyCodeSubmitted);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  final AuthRepository _authRepository;

  Future<void> _onVerifyCodeSubmitted(
    VerifyCodeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current = state is ResetPasswordState
        ? state as ResetPasswordState
        : const ResetPasswordState();

    emit(current.copyWith(
      isVerifying: true,
      clearVerifyError: true,
    ));

    final result = await _authRepository.verifyResetCode(
      email: event.email,
      token: event.token.trim(),
    );

    if (result.success) {
      emit(current.copyWith(
        isVerifying: false,
        isCodeVerified: true,
        clearVerifyError: true,
      ));
    } else {
      emit(current.copyWith(
        isVerifying: false,
        isCodeVerified: false,
        verifyError: result.message,
      ));
    }
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current = state is ResetPasswordState
        ? state as ResetPasswordState
        : const ResetPasswordState();

    if (event.password.length < 8) {
      emit(current.copyWith(
          resetError: 'Password must be at least 8 characters.'));
      return;
    }

    if (event.password != event.passwordConfirmation) {
      emit(current.copyWith(resetError: 'Passwords do not match.'));
      return;
    }

    emit(current.copyWith(isResetting: true, clearResetError: true));

    final result = await _authRepository.resetPassword(
      email: event.email,
      token: event.token.trim(),
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
    );

    if (result.success) {
      emit(current.copyWith(isResetting: false, isSuccess: true));
    } else {
      emit(current.copyWith(isResetting: false, resetError: result.message));
    }
  }
}
