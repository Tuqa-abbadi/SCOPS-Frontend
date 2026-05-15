import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class ForgotPasswordBloc extends Bloc<AuthEvent, AuthState> {
  ForgotPasswordBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const ForgotPasswordState()) {
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
  }

  final AuthRepository _authRepository;

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current = state is ForgotPasswordState
        ? state as ForgotPasswordState
        : const ForgotPasswordState();
    final email = event.email.trim();

    if (email.isEmpty) {
      emit(current.copyWith(errorMessage: 'Please enter your email.'));
      return;
    }

    emit(
      current.copyWith(
        isLoading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await _authRepository.forgotPassword(email: email);

    if (result.success) {
      emit(
        current.copyWith(
          isLoading: false,
          successMessage: result.message,
          clearError: true,
        ),
      );
    } else {
      emit(
        current.copyWith(
          isLoading: false,
          errorMessage: result.message,
          clearSuccess: true,
        ),
      );
    }
  }
}
