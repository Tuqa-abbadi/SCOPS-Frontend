part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashVisible extends SplashState {
  const SplashVisible();
}

class SplashNavigateToOnboarding extends SplashState {
  const SplashNavigateToOnboarding();
}

class SplashNavigateToDashboard extends SplashState {
  const SplashNavigateToDashboard();
}

class SplashNavigateToAdminDashboard extends SplashState {
  const SplashNavigateToAdminDashboard();
}