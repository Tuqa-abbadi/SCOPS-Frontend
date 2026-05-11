import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardInitial()) {
    on<DashboardLoaded>(_onDashboardLoaded);
  }

  Future<void> _onDashboardLoaded(
    DashboardLoaded event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    // Simulate API call — replace with real service call when ready
    await Future.delayed(const Duration(milliseconds: 600));

    emit(const DashboardDataLoaded(
      monthlySpend: r'$284.97',
      dueSoon: 3,
      activeSubscriptions: 12,
      upcomingRenewals: [
        RenewalItem(name: 'Netflix', date: 'Jan 5', price: r'$15.99'),
        RenewalItem(name: 'Spotify', date: 'Jan 8', price: r'$9.99'),
        RenewalItem(name: 'Adobe CC', date: 'Jan 12', price: r'$54.99'),
      ],
    ));
  }
}
