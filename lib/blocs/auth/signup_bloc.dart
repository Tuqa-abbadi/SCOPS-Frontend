import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class SignupBloc extends Bloc<AuthEvent, AuthState> {
  SignupBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const SignupState()) {
    on<SignupNextStep>(_onNextStep);
    on<SignupPreviousStep>(_onPreviousStep);
    on<SignupPageChanged>(_onPageChanged);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<TogglePasswordVisibility>(_onTogglePassword);
  }

  final AuthRepository _authRepository;
  static const int totalSteps = 4;

  void _onTogglePassword(
    TogglePasswordVisibility event,
    Emitter<AuthState> emit,
  ) {
    final current =
        state is SignupState ? state as SignupState : const SignupState();
    emit(current.copyWith(showPassword: !current.showPassword));
  }

  void _onNextStep(SignupNextStep event, Emitter<AuthState> emit) {
    final current =
        state is SignupState ? state as SignupState : const SignupState();
    if (current.currentStep < totalSteps - 1) {
      emit(
        current.copyWith(
          currentStep: current.currentStep + 1,
          clearError: true,
        ),
      );
    }
  }

  void _onPreviousStep(SignupPreviousStep event, Emitter<AuthState> emit) {
    final current =
        state is SignupState ? state as SignupState : const SignupState();
    if (current.currentStep > 0) {
      emit(
        current.copyWith(
          currentStep: current.currentStep - 1,
          clearError: true,
        ),
      );
    } else {
      emit(const SignupGoBack());
    }
  }

  void _onPageChanged(SignupPageChanged event, Emitter<AuthState> emit) {
    final current =
        state is SignupState ? state as SignupState : const SignupState();
    emit(current.copyWith(currentStep: event.step));
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current =
        state is SignupState ? state as SignupState : const SignupState();

    if (event.firstName.trim().isEmpty) {
      emit(current.copyWith(errorMessage: 'Please enter your first name.'));
      return;
    }
    if (event.lastName.trim().isEmpty) {
      emit(current.copyWith(errorMessage: 'Please enter your last name.'));
      return;
    }
    if (event.email.trim().isEmpty) {
      emit(current.copyWith(errorMessage: 'Please enter your email.'));
      return;
    }
    final phoneDigits = event.phone.trim().replaceAll(RegExp(r'\D'), '');
    final localPhoneDigits =
        phoneDigits.startsWith('962') ? phoneDigits.substring(3) : phoneDigits;
    final normalizedPhone = localPhoneDigits;

    if (localPhoneDigits.isEmpty) {
      emit(current.copyWith(errorMessage: 'Please enter your phone number.'));
      return;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(localPhoneDigits)) {
      emit(
        current.copyWith(
          errorMessage: 'Phone number must be 10 digits after +962.',
        ),
      );
      return;
    }
    if (event.password.isEmpty) {
      emit(current.copyWith(errorMessage: 'Please enter a password.'));
      return;
    }
    if (event.password.length < 6) {
      emit(
        current.copyWith(
          errorMessage: 'Password must be at least 6 characters.',
        ),
      );
      return;
    }

    emit(current.copyWith(isLoading: true, clearError: true));

    final result = await _authRepository.signup(
      firstName: event.firstName.trim(),
      lastName: event.lastName.trim(),
      email: event.email.trim(),
      phone: normalizedPhone,
      password: event.password,
    );

    if (result.success) {
      emit(SignupSuccess(
        email: event.email.trim(),
        message: result.message,
      ));
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
