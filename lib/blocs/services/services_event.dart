part of 'services_bloc.dart';

abstract class ServicesEvent extends Equatable {
  const ServicesEvent();

  @override
  List<Object?> get props => [];
}

// Triggered once in initState — fetches categories + services in parallel.
class ServicesLoaded extends ServicesEvent {
  const ServicesLoaded();
}

// Null categoryId → "All" (GET /api/services).
// Non-null → GET /api/services?category_id={id}.
class ServicesCategorySelected extends ServicesEvent {
  const ServicesCategorySelected(this.categoryId);

  final int? categoryId;

  @override
  List<Object?> get props => [categoryId];
}

class ServicesSearchChanged extends ServicesEvent {
  const ServicesSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

// Fetch full service details + plans from GET /api/services/{id}.
class ServiceDetailRequested extends ServicesEvent {
  const ServiceDetailRequested(this.serviceId);

  final String serviceId;

  @override
  List<Object?> get props => [serviceId];
}

// Select a plan by id. Pass null to deselect.
class ServicePlanSelected extends ServicesEvent {
  const ServicePlanSelected(this.planId);

  final int? planId;

  @override
  List<Object?> get props => [planId];
}
