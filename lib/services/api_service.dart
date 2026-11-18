
import 'package:dio/dio.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://fakestoreapi.com',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return 'Server error: ${error.response?.statusCode}';
    }

    return 'Unable to connect. Please check your internet connection.';
  }
}
