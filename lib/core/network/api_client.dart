import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/local_storage.dart';
import 'api_endpoints.dart';
import 'api_exceptions.dart';

part 'api_client.g.dart';

class ApiClient {
  ApiClient({
    required Dio dio,
    required LocalStorage storage,
  })  : _dio = dio,
        _storage = storage {
    _setupInterceptors();
  }

  final Dio _dio;
  final LocalStorage _storage;

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      _LoggerInterceptor(),
    ]);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage);

  final LocalStorage _storage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken != null) {
          final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
          final response = await dio.post(
            ApiEndpoints.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          final newAccessToken = response.data['accessToken'] as String?;
          final newRefreshToken = response.data['refreshToken'] as String?;

          if (newAccessToken != null) {
            await _storage.saveAccessToken(newAccessToken);
            if (newRefreshToken != null) {
              await _storage.saveRefreshToken(newRefreshToken);
            }

            err.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';
            final cloneReq = await Dio(
              BaseOptions(baseUrl: ApiEndpoints.baseUrl),
            ).fetch(err.requestOptions);
            return handler.resolve(cloneReq);
          }
        }

        await _storage.clearTokens();
      } catch (e) {
        await _storage.clearTokens();
      }
    }
    handler.next(err);
  }
}

class _LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final message = '''
┌──────────────────────────────────────────────────────────────────────
│ REQUEST
├──────────────────────────────────────────────────────────────────────
│ ${options.method} ${options.uri}
│ Headers: ${options.headers}
│ Body: ${options.data}
└──────────────────────────────────────────────────────────────────────
''';
    // ignore: avoid_print
    print(message);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final message = '''
┌──────────────────────────────────────────────────────────────────────
│ RESPONSE [${response.statusCode}]
├──────────────────────────────────────────────────────────────────────
│ ${response.requestOptions.method} ${response.requestOptions.uri}
│ Data: ${response.data}
└──────────────────────────────────────────────────────────────────────
''';
    // ignore: avoid_print
    print(message);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = '''
┌──────────────────────────────────────────────────────────────────────
│ ERROR [${err.response?.statusCode}]
├──────────────────────────────────────────────────────────────────────
│ ${err.requestOptions.method} ${err.requestOptions.uri}
│ Message: ${err.message}
│ Data: ${err.response?.data}
└──────────────────────────────────────────────────────────────────────
''';
    // ignore: avoid_print
    print(message);
    handler.next(err);
  }
}

@riverpod
Dio dio(DioRef ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}

@riverpod
ApiClient apiClient(ApiClientRef ref) {
  return ApiClient(
    dio: ref.watch(dioProvider),
    storage: ref.watch(localStorageProvider),
  );
}
