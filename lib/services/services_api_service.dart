import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';

class ServicesApiService {
  const ServicesApiService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<Response<dynamic>> getServices() => _dio.get(ApiConstants.services);

  Future<Response<dynamic>> getServicesByCategory(int categoryId) =>
      _dio.get(
        ApiConstants.services,
        queryParameters: {'category_id': categoryId},
      );

  Future<Response<dynamic>> getServicesWithSearch(String query) =>
      _dio.get(
        ApiConstants.services,
        queryParameters: {'search': query},
      );

  Future<Response<dynamic>> getServiceById(int id) =>
      _dio.get(ApiConstants.serviceById(id));

  // Fallback ①: GET /api/services/{id}/plans
  Future<Response<dynamic>> getServicePlans(int serviceId) =>
      _dio.get(ApiConstants.servicePlans(serviceId));

  // Fallback ②: GET /api/service-plans?service_id={id}
  Future<Response<dynamic>> getServicePlansByServiceId(int serviceId) =>
      _dio.get(
        ApiConstants.servicePlansList,
        queryParameters: {'service_id': serviceId},
      );
}
