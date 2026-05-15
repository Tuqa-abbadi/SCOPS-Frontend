import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';

class UserCubit extends Cubit<UserModel?> {
  UserCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(null);

  final AuthRepository _authRepository;

  Future<void> loadUser() async {
    final user = await _authRepository.getUser();
    emit(user);
  }

  void setUser(UserModel? user) => emit(user);

  void clearUser() => emit(null);
}
