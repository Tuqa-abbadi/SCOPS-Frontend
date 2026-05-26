import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/auth_repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  final AuthRepository _authRepository;

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    emit(const SplashVisible());

    final isLoggedIn = await _authRepository
        .validateSession(allowNetworkFallback: false)
        .timeout(const Duration(seconds: 12), onTimeout: () => false);

    await Future.delayed(const Duration(seconds: 3));

    if (isLoggedIn) {
      final user = await _authRepository.getUser();
      if (user != null && user.isAdmin) {
        emit(const SplashNavigateToAdminDashboard());
      } else {
        emit(const SplashNavigateToDashboard());
      }
    } else {
      emit(const SplashNavigateToOnboarding());
    }
  }

}
