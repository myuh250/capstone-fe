import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  String get userMessage => message;

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == null) {
          return const UnknownException('An unknown error occurred.');
        }

        final message = data is Map<String, dynamic>
            ? data['message'] as String? ?? 'Request failed'
            : 'Request failed';

        return switch (statusCode) {
          400 => BadRequestException(message, statusCode),
          401 => UnauthorizedException(message, statusCode),
          403 => ForbiddenException(message, statusCode),
          404 => NotFoundException(message, statusCode),
          409 => ConflictException(message, statusCode),
          422 => ValidationException(message, statusCode),
          429 => TooManyRequestsException(message, statusCode),
          >= 500 => ServerException(message, statusCode),
          _ => UnknownException(message, statusCode),
        };

      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException('Security certificate error.');

      case DioExceptionType.cancel:
        return const CancelledException('Request was cancelled.');

      case DioExceptionType.unknown:
        return const UnknownException('An unknown error occurred.');
    }
  }

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  const NetworkException(super.message, [super.statusCode]);
}

class BadRequestException extends ApiException {
  const BadRequestException(super.message, [super.statusCode]);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, [super.statusCode]);

  @override
  String get userMessage => 'Please log in to continue.';
}

class ForbiddenException extends ApiException {
  const ForbiddenException(super.message, [super.statusCode]);

  @override
  String get userMessage => 'You do not have permission to access this.';
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message, [super.statusCode]);

  @override
  String get userMessage => 'The requested resource was not found.';
}

class ConflictException extends ApiException {
  const ConflictException(super.message, [super.statusCode]);
}

class ValidationException extends ApiException {
  const ValidationException(super.message, [super.statusCode]);
}

class TooManyRequestsException extends ApiException {
  const TooManyRequestsException(super.message, [super.statusCode]);

  @override
  String get userMessage => 'Too many requests. Please try again later.';
}

class ServerException extends ApiException {
  const ServerException(super.message, [super.statusCode]);

  @override
  String get userMessage => 'Server error. Please try again later.';
}

class CancelledException extends ApiException {
  const CancelledException(super.message, [super.statusCode]);
}

class UnknownException extends ApiException {
  const UnknownException(super.message, [super.statusCode]);

  @override
  String get userMessage => 'Something went wrong. Please try again.';
}
