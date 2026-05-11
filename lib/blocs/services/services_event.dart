part of 'services_bloc.dart';

abstract class ServicesEvent extends Equatable {
  const ServicesEvent();
  @override
  List<Object> get props => [];
}

class ServicesLoaded extends ServicesEvent {
  const ServicesLoaded();
}

class ServicesCategoryChanged extends ServicesEvent {
  final String category;
  const ServicesCategoryChanged(this.category);
  @override
  List<Object> get props => [category];
}

class ServicesSearchChanged extends ServicesEvent {
  final String query;
  const ServicesSearchChanged(this.query);
  @override
  List<Object> get props => [query];
}