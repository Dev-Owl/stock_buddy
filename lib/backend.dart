import 'dart:convert';
import 'package:dio/dio.dart';

const String debugUrl = "http://127.0.0.1:5984/";
const String userName = "admin";
const String userPassword = "admin";

class StockBuddyBackend {
  static StockBuddyBackend? _instance;

  static StockBuddyBackend getInstance({String? url}) {
    _instance ??= StockBuddyBackend(url ?? debugUrl);
    return _instance!;
  }

  StockBuddyBackend(
    this.baseUrl,
  );

  final String baseUrl;

  Dio getDioClient() {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Authorization': 'Basic ${base64Encode(
            utf8.encode('$userName:$userPassword'),
          )}',
        },
      ),
    );
  }

  Future<Response<Map<String, dynamic>>> get(
    String path,
    Map<String, dynamic>? queryParameters,
  ) async {
    final response = await getDioClient().get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get data from $path: ${response.statusCode}',
      );
    }
    return response;
  }

  Future<T> requestWithConverter<T>(
    Future<Response<Map<String, dynamic>>> request,
    T Function(Map<String, dynamic>) converter,
  ) async {
    final response = await request;
    return converter(response.data!);
  }
}
