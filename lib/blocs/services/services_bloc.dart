import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'services_event.dart';
part 'services_state.dart';

final _mockServices = [
  const ServiceModel(id: '1', name: 'Netflix', category: 'Entertainment', icon: '🎬', description: 'Stream movies, TV shows, and more on any device.', plans: ['Basic', 'Standard', 'Premium'], startingPrice: 6.99, color: Color(0xFFE50914)),
  const ServiceModel(id: '2', name: 'Spotify', category: 'Music', icon: '🎵', description: 'Music streaming with millions of songs and podcasts.', plans: ['Free', 'Individual', 'Duo', 'Family'], startingPrice: 9.99, color: Color(0xFF1DB954)),
  const ServiceModel(id: '3', name: 'Adobe CC', category: 'Productivity', icon: '🎨', description: 'Creative cloud suite: Photoshop, Illustrator, Premiere & more.', plans: ['Photography', 'All Apps', 'Single App'], startingPrice: 9.99, color: Color(0xFFFF0000)),
  const ServiceModel(id: '4', name: 'YouTube Premium', category: 'Entertainment', icon: '📺', description: 'Ad-free YouTube with background play and downloads.', plans: ['Individual', 'Family', 'Student'], startingPrice: 13.99, color: Color(0xFFFF0000)),
  const ServiceModel(id: '5', name: 'iCloud+', category: 'Cloud Storage', icon: '☁️', description: 'Apple cloud storage with advanced privacy features.', plans: ['50GB', '200GB', '2TB'], startingPrice: 0.99, color: Color(0xFF0071E3)),
  const ServiceModel(id: '6', name: 'Google One', category: 'Cloud Storage', icon: '🔵', description: 'Google storage across Drive, Gmail, and Photos.', plans: ['Basic', 'Standard', 'Premium'], startingPrice: 1.99, color: Color(0xFF4285F4)),
  const ServiceModel(id: '7', name: 'Microsoft 365', category: 'Productivity', icon: '💼', description: 'Word, Excel, PowerPoint and 1TB of OneDrive storage.', plans: ['Personal', 'Family', 'Business'], startingPrice: 6.99, color: Color(0xFF0078D4)),
  const ServiceModel(id: '8', name: 'Apple Music', category: 'Music', icon: '🎶', description: 'Over 100 million songs with lossless audio.', plans: ['Individual', 'Student', 'Family'], startingPrice: 10.99, color: Color(0xFFFC3C44)),
  const ServiceModel(id: '9', name: 'Disney+', category: 'Entertainment', icon: '✨', description: 'Disney, Marvel, Star Wars, Pixar and National Geographic.', plans: ['Basic', 'Premium'], startingPrice: 7.99, color: Color(0xFF113CCF)),
  const ServiceModel(id: '10', name: 'GitHub', category: 'Developer', icon: '💻', description: 'Code hosting, CI/CD, and collaboration for developers.', plans: ['Free', 'Team', 'Enterprise'], startingPrice: 4.00, color: Color(0xFF6E40C9)),
  const ServiceModel(id: '11', name: 'Notion', category: 'Productivity', icon: '📝', description: 'All-in-one workspace for notes, tasks, and databases.', plans: ['Free', 'Plus', 'Business'], startingPrice: 10.00, color: Color(0xFF9AB0B4)),
  const ServiceModel(id: '12', name: 'Figma', category: 'Developer', icon: '🖌️', description: 'Collaborative design and prototyping tool for teams.', plans: ['Starter', 'Professional', 'Organization'], startingPrice: 12.00, color: Color(0xFFF24E1E)),
];

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  ServicesBloc() : super(const ServicesInitial()) {
    on<ServicesLoaded>(_onLoaded);
    on<ServicesCategoryChanged>(_onCategoryChanged);
    on<ServicesSearchChanged>(_onSearchChanged);
  }

  Future<void> _onLoaded(ServicesLoaded event, Emitter<ServicesState> emit) async {
    emit(const ServicesLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(ServicesDataLoaded(
      allServices: _mockServices,
      filteredServices: _mockServices,
      selectedCategory: 'All',
      searchQuery: '',
    ));
  }

  void _onCategoryChanged(ServicesCategoryChanged event, Emitter<ServicesState> emit) {
    final current = state as ServicesDataLoaded;
    emit(ServicesDataLoaded(
      allServices: current.allServices,
      filteredServices: _filter(current.allServices, event.category, current.searchQuery),
      selectedCategory: event.category,
      searchQuery: current.searchQuery,
    ));
  }

  void _onSearchChanged(ServicesSearchChanged event, Emitter<ServicesState> emit) {
    final current = state as ServicesDataLoaded;
    emit(ServicesDataLoaded(
      allServices: current.allServices,
      filteredServices: _filter(current.allServices, current.selectedCategory, event.query),
      selectedCategory: current.selectedCategory,
      searchQuery: event.query,
    ));
  }

  List<ServiceModel> _filter(List<ServiceModel> all, String category, String query) {
    return all.where((s) {
      final matchesCategory = category == 'All' || s.category == category;
      final matchesQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query.toLowerCase()) ||
          s.category.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }
}