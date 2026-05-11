part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

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
  final int step;
  const SignupPageChanged(this.step);

  @override
  List<Object> get props => [step];
}

class SignupSubmitted extends AuthEvent {
  final String firstName;
  final String middleName;
  final String email;
  final String phone;
  final String password;

  const SignupSubmitted({
    required this.firstName,
    required this.middleName,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object> get props => [firstName, middleName, email, phone, password];
}

class TogglePasswordVisibility extends AuthEvent {
  const TogglePasswordVisibility();
}

class AuthReset extends AuthEvent {
  const AuthReset();
}
