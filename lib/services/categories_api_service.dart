import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';

class CategoriesApiService {
  const CategoriesApiService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<Response<dynamic>> getCategories() => _dio.get(ApiConstants.categories);
}
