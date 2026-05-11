part of 'dashboard_bloc.dart';

class RenewalItem extends Equatable {
  final String name;
  final String date;
  final String price;

  const RenewalItem({
    required this.name,
    required this.date,
    required this.price,
  });

  @override
  List<Object> get props => [name, date, price];
}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardDataLoaded extends DashboardState {
  final String monthlySpend;
  final int dueSoon;
  final int activeSubscriptions;
  final List<RenewalItem> upcomingRenewals;

  const DashboardDataLoaded({
    required this.monthlySpend,
    required this.dueSoon,
    required this.activeSubscriptions,
    required this.upcomingRenewals,
  });

  @override
  List<Object> get props => [
        monthlySpend,
        dueSoon,
        activeSubscriptions,
        upcomingRenewals,
      ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}
