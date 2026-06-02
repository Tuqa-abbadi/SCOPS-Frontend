import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class EmailVerificationBloc extends Bloc<AuthEvent, AuthState> {
  EmailVerificationBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const EmailVerificationState()) {
    on<EmailVerificationSubmitted>(_onEmailVerificationSubmitted);
  }

  final AuthRepository _authRepository;

  Future<void> _onEmailVerificationSubmitted(
    EmailVerificationSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current = state is EmailVerificationState
        ? state as EmailVerificationState
        : const EmailVerificationState();
    final token = event.token.trim();

    if (token.length != 6 || int.tryParse(token) == null) {
      emit(current.copyWith(errorMessage: 'Enter the 6-digit code.'));
      return;
    }

    emit(current.copyWith(
      isVerifying: true,
      clearError: true,
      clearSuccess: true,
    ));

    final result = await _authRepository.verifyEmail(
      email: event.email.trim(),
      token: token,
    );

    if (result.success) {
      if (event.password != null && event.password!.isNotEmpty) {
        final loginResult = await _authRepository.login(
          email: event.email.trim(),
          password: event.password!,
        );

        if (!loginResult.success) {
          emit(current.copyWith(
            isVerifying: false,
            isVerified: false,
            errorMessage: loginResult.message,
            clearSuccess: true,
          ));
          return;
        }
      }

      emit(current.copyWith(
        isVerifying: false,
        isVerified: true,
        successMessage: result.message,
        clearError: true,
      ));
    } else {
      emit(current.copyWith(
        isVerifying: false,
        isVerified: false,
        errorMessage: result.message,
        clearSuccess: true,
      ));
    }
  }
}
