import 'package:dio/dio.dart';

class DioClientProvider {
  final Dio _dio;

  DioClientProvider()
      : _dio = Dio(
    BaseOptions(
      baseUrl: "https://api.openai.com/v1", // Replace with your actual API URL
      connectTimeout: const Duration(microseconds: 10000),
      receiveTimeout: const Duration(microseconds: 10000),
      headers: {
        "Authorization": "Bearer YOUR_API_KEY", // Replace with your API key
        "Content-Type": "application/json",
      },
    ),
  );

  // Method to perform POST request
  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } catch (e) {
      throw Exception('Dio Error: $e');
    }
  }

  // Access to Dio instance if needed
  Dio get dio => _dio;
}
