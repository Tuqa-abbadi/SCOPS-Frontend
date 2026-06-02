import 'package:equatable/equatable.dart';

import '../../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

class AuthFailure extends AuthState {
  const AuthFailure({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}

class LoginState extends AuthState {
  const LoginState({
    this.showPassword = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final bool showPassword;
  final bool isLoading;
  final String? errorMessage;

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
  const LoginSuccess({this.user});

  final UserModel? user;

  @override
  List<Object> get props => [if (user != null) user!];
}

class SignupState extends AuthState {
  const SignupState({
    this.currentStep = 0,
    this.showPassword = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final int currentStep;
  final bool showPassword;
  final bool isLoading;
  final String? errorMessage;

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
  List<Object> get props => [
        currentStep,
        showPassword,
        isLoading,
        errorMessage ?? '',
      ];
}

class SignupSuccess extends AuthState {
  const SignupSuccess({
    required this.email,
    required this.message,
  });

  final String email;
  final String message;

  @override
  List<Object> get props => [email, message];
}

class SignupGoBack extends AuthState {
  const SignupGoBack();
}

class LogoutInProgress extends AuthState {
  const LogoutInProgress();
}

class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}

class LogoutFailure extends AuthState {
  const LogoutFailure({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}

class ResetPasswordState extends AuthState {
  const ResetPasswordState({
    this.isVerifying = false,
    this.isCodeVerified = false,
    this.verifyError,
    this.isResetting = false,
    this.isSuccess = false,
    this.resetError,
  });

  final bool isVerifying;
  final bool isCodeVerified;
  final String? verifyError;
  final bool isResetting;
  final bool isSuccess;
  final String? resetError;

  ResetPasswordState copyWith({
    bool? isVerifying,
    bool? isCodeVerified,
    String? verifyError,
    bool clearVerifyError = false,
    bool? isResetting,
    bool? isSuccess,
    String? resetError,
    bool clearResetError = false,
  }) {
    return ResetPasswordState(
      isVerifying: isVerifying ?? this.isVerifying,
      isCodeVerified: isCodeVerified ?? this.isCodeVerified,
      verifyError:
          clearVerifyError ? null : (verifyError ?? this.verifyError),
      isResetting: isResetting ?? this.isResetting,
      isSuccess: isSuccess ?? this.isSuccess,
      resetError: clearResetError ? null : (resetError ?? this.resetError),
    );
  }

  @override
  List<Object> get props => [
        isVerifying,
        isCodeVerified,
        verifyError ?? '',
        isResetting,
        isSuccess,
        resetError ?? '',
      ];
}

class EmailVerificationState extends AuthState {
  const EmailVerificationState({
    this.isVerifying = false,
    this.isVerified = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isVerifying;
  final bool isVerified;
  final String? errorMessage;
  final String? successMessage;

  EmailVerificationState copyWith({
    bool? isVerifying,
    bool? isVerified,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return EmailVerificationState(
      isVerifying: isVerifying ?? this.isVerifying,
      isVerified: isVerified ?? this.isVerified,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object> get props => [
        isVerifying,
        isVerified,
        errorMessage ?? '',
        successMessage ?? '',
      ];
}

class ForgotPasswordState extends AuthState {
  const ForgotPasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object> get props => [
        isLoading,
        errorMessage ?? '',
        successMessage ?? '',
      ];
}
