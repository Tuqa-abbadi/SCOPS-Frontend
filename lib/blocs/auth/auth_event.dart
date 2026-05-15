import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

class SignupNextStep extends AuthEvent {
  const SignupNextStep();
}

class SignupPreviousStep extends AuthEvent {
  const SignupPreviousStep();
}

class SignupPageChanged extends AuthEvent {
  const SignupPageChanged(this.step);

  final int step;

  @override
  List<Object> get props => [step];
}

class SignupSubmitted extends AuthEvent {
  const SignupSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;

  @override
  List<Object> get props => [firstName, lastName, email, phone, password];
}

class ForgotPasswordSubmitted extends AuthEvent {
  const ForgotPasswordSubmitted({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

class TogglePasswordVisibility extends AuthEvent {
  const TogglePasswordVisibility();
}

class AuthReset extends AuthEvent {
  const AuthReset();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
