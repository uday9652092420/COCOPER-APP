import 'package:dio/dio.dart';

sealed class AppException implements Exception {
  const AppException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });

  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}

final class SessionExpiredException extends AppException {
  const SessionExpiredException() : super('session_expired', statusCode: 401);
}

final class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.statusCode,
    super.fieldErrors,
  });
}

final class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

AppException mapDioException(DioException error) {
  final status = error.response?.statusCode;
  if (status == 401 || status == 403) return const SessionExpiredException();

  final body = error.response?.data;
  final map = body is Map<dynamic, dynamic>
      ? body.map((key, value) => MapEntry('$key', value))
      : const <String, dynamic>{};
  final message = map['message']?.toString() ?? 'something_went_wrong';
  final rawFieldErrors = map['fieldErrors'];
  final fieldErrors = rawFieldErrors is Map<dynamic, dynamic>
      ? rawFieldErrors.map((key, value) => MapEntry('$key', '$value'))
      : const <String, String>{};

  if (status == 400 || status == 409 || status == 422) {
    return ValidationException(
      message,
      statusCode: status,
      fieldErrors: fieldErrors,
    );
  }
  if (error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return const NetworkException('network_error');
  }
  return ServerException(message, statusCode: status);
}
