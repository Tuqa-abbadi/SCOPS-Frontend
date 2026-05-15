import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/profile_repository.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

export 'change_password_event.dart';
export 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc({ProfileRepository? profileRepository})
      : _repository = profileRepository ?? ProfileRepository(),
        super(const ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>(_onSubmitted);
    on<ChangePasswordReset>(_onReset);
  }

  final ProfileRepository _repository;

  Future<void> _onSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    final current = event.currentPassword.trim();
    final next = event.newPassword.trim();
    final confirm = event.confirmPassword.trim();

    if (current.isEmpty) {
      emit(const ChangePasswordFailure(
          error: 'Please enter your current password.'));
      return;
    }
    if (next.isEmpty) {
      emit(const ChangePasswordFailure(
          error: 'Please enter a new password.'));
      return;
    }
    if (next.length < 8) {
      emit(const ChangePasswordFailure(
          error: 'New password must be at least 8 characters.'));
      return;
    }
    if (next != confirm) {
      emit(const ChangePasswordFailure(
          error: 'New password and confirmation do not match.'));
      return;
    }

    emit(const ChangePasswordLoading());

    final result = await _repository.changePassword(
      currentPassword: current,
      newPassword: next,
      newPasswordConfirmation: confirm,
    );

    if (result.success) {
      emit(ChangePasswordSuccess(message: result.message));
    } else {
      emit(ChangePasswordFailure(error: result.message));
    }
  }

  void _onReset(ChangePasswordReset event, Emitter<ChangePasswordState> emit) {
    emit(const ChangePasswordInitial());
  }
}
