import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  static const int totalPages = 4;

  OnboardingBloc()
      : super(const OnboardingInProgress(currentIndex: 0, totalPages: totalPages)) {
    on<OnboardingNextPage>(_onNextPage);
    on<OnboardingSkip>(_onSkip);
    on<OnboardingPageChanged>(_onPageChanged);
  }

  void _onNextPage(OnboardingNextPage event, Emitter<OnboardingState> emit) {
    final current = state as OnboardingInProgress;
    if (current.currentIndex < totalPages - 1) {
      emit(OnboardingInProgress(
        currentIndex: current.currentIndex + 1,
        totalPages: totalPages,
      ));
    } else {
      emit(const OnboardingComplete());
    }
  }

  void _onSkip(OnboardingSkip event, Emitter<OnboardingState> emit) {
    emit(const OnboardingComplete());
  }

  void _onPageChanged(OnboardingPageChanged event, Emitter<OnboardingState> emit) {
    emit(OnboardingInProgress(
      currentIndex: event.index,
      totalPages: totalPages,
    ));
  }
}
