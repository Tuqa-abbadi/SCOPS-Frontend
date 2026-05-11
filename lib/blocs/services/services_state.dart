part of 'services_bloc.dart';

class ServiceModel extends Equatable {
  final String id;
  final String name;
  final String category;
  final String icon;
  final String description;
  final List<String> plans;
  final double startingPrice;
  final Color color;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.description,
    required this.plans,
    required this.startingPrice,
    required this.color,
  });

  @override
  List<Object> get props => [id];
}

abstract class ServicesState extends Equatable {
  const ServicesState();
  @override
  List<Object> get props => [];
}

class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

class ServicesDataLoaded extends ServicesState {
  final List<ServiceModel> allServices;
  final List<ServiceModel> filteredServices;
  final String selectedCategory;
  final String searchQuery;

  const ServicesDataLoaded({
    required this.allServices,
    required this.filteredServices,
    required this.selectedCategory,
    required this.searchQuery,
  });

  @override
  List<Object> get props => [filteredServices, selectedCategory, searchQuery];
}