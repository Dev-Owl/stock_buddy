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

  String encodeQueryComponent(String queryComponent) {
    return Uri.encodeQueryComponent(queryComponent);
  }

  String encodePath(String path) {
    return Uri.encodeFull(path);
  }

  Future<Response<Map<String, dynamic>>> put(
    String path,
    Map<String, dynamic> data,
  ) async {
    final dio = getDioClient();
    // Add JSON content type header
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    final response = await dio.put<Map<String, dynamic>>(
      encodePath(path),
      data: data,
    );
    final successStatusCodes = [200, 201, 202];
    if (successStatusCodes.contains(response.statusCode) == false) {
      throw Exception(
        'Failed to post data to $path: ${response.statusCode}',
      );
    }
    return response;
  }

  Future<Response<Map<String, dynamic>>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final dio = getDioClient();
    dio.options.headers['Accept'] = 'application/json';
    final response = await dio.delete<Map<String, dynamic>>(
      encodePath(path),
      queryParameters: queryParameters,
    );
    final successStatusCodes = [200, 201, 202];
    if (successStatusCodes.contains(response.statusCode) == false) {
      throw Exception(
        'Failed to delete data from $path: ${response.statusCode}',
      );
    }
    return response;
  }

  Future<Response<Map<String, dynamic>>> head(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final dio = getDioClient();
    final response = await dio.head<Map<String, dynamic>>(
      encodePath(path),
      queryParameters: queryParameters,
    );
    final successStatusCodes = [200, 201, 202];
    if (successStatusCodes.contains(response.statusCode) == false) {
      throw Exception(
        'Failed to head data from $path: ${response.statusCode}',
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
