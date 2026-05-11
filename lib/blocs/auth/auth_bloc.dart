import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// ---------------------------------------------------------------------------
// LoginBloc
// ---------------------------------------------------------------------------
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
    final current = state as LoginState;
    emit(current.copyWith(showPassword: !current.showPassword));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current = state as LoginState;

    if (event.email.trim().isEmpty && event.password.isEmpty) {
      emit(current.copyWith(errorMessage: 'Please enter your email and password.'));
      return;
    }
    if (event.email.trim().isEmpty) {
      emit(current.copyWith(errorMessage: 'Please enter your email.'));
      return;
    }
    if (event.password.isEmpty) {
      emit(current.copyWith(errorMessage: 'Please enter your password.'));
      return;
    }

    emit(current.copyWith(isLoading: true, clearError: true));

    // TODO: uncomment when backend is ready
    // final result = await _authRepository.login(
    //   email: event.email,
    //   password: event.password,
    // );
    // if (result.success) {
    //   emit(const LoginSuccess());
    // } else {
    //   emit(current.copyWith(isLoading: false, errorMessage: result.message));
    // }

    await Future.delayed(const Duration(milliseconds: 400));
    emit(const LoginSuccess());
  }
}

// ---------------------------------------------------------------------------
// SignupBloc
// ---------------------------------------------------------------------------
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
    final current = state as SignupState;
    emit(current.copyWith(showPassword: !current.showPassword));
  }

  void _onNextStep(SignupNextStep event, Emitter<AuthState> emit) {
    final current = state as SignupState;
    if (current.currentStep < totalSteps - 1) {
      emit(current.copyWith(currentStep: current.currentStep + 1, clearError: true));
    }
  }

  void _onPreviousStep(SignupPreviousStep event, Emitter<AuthState> emit) {
    final current = state as SignupState;
    if (current.currentStep > 0) {
      emit(current.copyWith(currentStep: current.currentStep - 1, clearError: true));
    } else {
      emit(const SignupGoBack());
    }
  }

  void _onPageChanged(SignupPageChanged event, Emitter<AuthState> emit) {
    final current = state as SignupState;
    emit(current.copyWith(currentStep: event.step));
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current = state as SignupState;

    if (event.password.isEmpty) {
      emit(current.copyWith(errorMessage: 'Please enter a password.'));
      return;
    }
    if (event.password.length < 6) {
      emit(current.copyWith(errorMessage: 'Password must be at least 6 characters.'));
      return;
    }

    emit(current.copyWith(isLoading: true, clearError: true));

    // TODO: uncomment when backend is ready
    // final result = await _authRepository.signup(
    //   firstName: event.firstName,
    //   middleName: event.middleName,
    //   email: event.email,
    //   phone: event.phone,
    //   password: event.password,
    // );
    // if (result.success) {
    //   emit(const SignupSuccess());
    // } else {
    //   emit(current.copyWith(isLoading: false, errorMessage: result.message));
    // }

    await Future.delayed(const Duration(milliseconds: 400));
    emit(const SignupSuccess());
  }
}