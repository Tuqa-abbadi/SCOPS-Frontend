part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// --- Shared ---

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final String message;
  const AuthSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthFailure extends AuthState {
  final String error;
  const AuthFailure({required this.error});

  @override
  List<Object> get props => [error];
}

// --- Login ---

class LoginState extends AuthState {
  final bool showPassword;
  final bool isLoading;
  final String? errorMessage;

  const LoginState({
    this.showPassword = false,
    this.isLoading = false,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? showPassword,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      showPassword: showPassword ?? this.showPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object> get props => [showPassword, isLoading, errorMessage ?? ''];
}

class LoginSuccess extends AuthState {
  const LoginSuccess();
}

// --- Signup ---

class SignupState extends AuthState {
  final int currentStep;
  final bool showPassword;
  final bool isLoading;
  final String? errorMessage;

  const SignupState({
    this.currentStep = 0,
    this.showPassword = false,
    this.isLoading = false,
    this.errorMessage,
  });

  SignupState copyWith({
    int? currentStep,
    bool? showPassword,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SignupState(
      currentStep: currentStep ?? this.currentStep,
      showPassword: showPassword ?? this.showPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object> get props => [currentStep, showPassword, isLoading, errorMessage ?? ''];
}

class SignupSuccess extends AuthState {
  const SignupSuccess();
}

class SignupGoBack extends AuthState {
  const SignupGoBack();
}
