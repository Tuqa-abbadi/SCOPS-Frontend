part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class OnboardingNextPage extends OnboardingEvent {
  const OnboardingNextPage();
}

class OnboardingSkip extends OnboardingEvent {
  const OnboardingSkip();
}

class OnboardingPageChanged extends OnboardingEvent {
  final int index;
  const OnboardingPageChanged(this.index);

  @override
  List<Object> get props => [index];
}
