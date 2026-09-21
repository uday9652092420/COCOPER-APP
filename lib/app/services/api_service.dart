import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/environment.dart';
import '../helpers/secure_storage_helper.dart';
import 'endpoints.dart';
import 'exceptions.dart';

abstract final class ApiService {
  static late final Dio _dio;
  static bool _refreshing = false;

  static void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Client-Platform': 'flutter',
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['requireAuthToken'] != false) {
            final token = await SecureStorageHelper.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              error.requestOptions.extra['retried'] != true &&
              await _refreshAccessToken()) {
            final request = error.requestOptions;
            request.extra['retried'] = true;
            request.headers['Authorization'] =
                'Bearer ${await SecureStorageHelper.getAccessToken()}';
            try {
              handler.resolve(await _dio.fetch<dynamic>(request));
              return;
            } on DioException {
              // The original 401 is mapped by the repository.
            }
          }
          handler.next(error);
        },
      ),
    );
    if (kDebugMode && !Environment.isProduction) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }
  }

  static Future<Response<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requireAuthToken = true,
  }) =>
      _execute<T>(
        () => _dio.get<T>(
          endpoint,
          queryParameters: queryParameters,
          options: Options(extra: {'requireAuthToken': requireAuthToken}),
        ),
      );

  static Future<Response<T>> post<T>(
    String endpoint, {
    Object? data,
    Map<String, String>? headers,
    bool requireAuthToken = true,
  }) =>
      _execute<T>(
        () => _dio.post<T>(
          endpoint,
          data: data,
          options: Options(
            headers: headers,
            extra: {'requireAuthToken': requireAuthToken},
          ),
        ),
      );

  static Future<Response<T>> request<T>(
    String endpoint, {
    required String method,
    Object? data,
    Map<String, String>? headers,
  }) =>
      _execute<T>(
        () => _dio.request<T>(
          endpoint,
          data: data,
          options: Options(method: method, headers: headers),
        ),
      );

  static Future<Response<T>> _execute<T>(
    Future<Response<T>> Function() operation,
  ) async {
    try {
      return await operation();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  static Future<bool> _refreshAccessToken() async {
    if (_refreshing) return false;
    final refreshToken = await SecureStorageHelper.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    _refreshing = true;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        EndPoints.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'requireAuthToken': false, 'retried': true}),
      );
      final token = response.data?['accessToken']?.toString();
      if (token == null || token.isEmpty) return false;
      await SecureStorageHelper.storeAccessToken(token);
      return true;
    } on DioException {
      await SecureStorageHelper.clearSession();
      return false;
    } finally {
      _refreshing = false;
    }
  }
}
