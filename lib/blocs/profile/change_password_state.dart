import 'package:equatable/equatable.dart';

abstract class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object?> get props => [];
}

class ChangePasswordInitial extends ChangePasswordState {
  const ChangePasswordInitial();
}

class ChangePasswordLoading extends ChangePasswordState {
  const ChangePasswordLoading();
}

class ChangePasswordSuccess extends ChangePasswordState {
  const ChangePasswordSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ChangePasswordFailure extends ChangePasswordState {
  const ChangePasswordFailure({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}
