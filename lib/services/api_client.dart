import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ApiClient {
  static const String baseUrl = 'https://jakbu-api.dsmhs.kr';
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 커스텀 로깅 인터셉터
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logRequest(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          return handler.next(response);
        },
        onError: (error, handler) {
          _logError(error);
          return handler.next(error);
        },
      ),
    );

    // 인증 토큰 인터셉터
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // 401 또는 403 에러 발생 시 토큰 리프레시 시도
          if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
            final refreshResult = await refreshAccessToken();

            if (refreshResult != null) {
              // 토큰 리프레시 성공 - 원래 요청 재시도
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer ${refreshResult['accessToken']}';

              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  void _logRequest(RequestOptions options) {
    if (options.queryParameters.isNotEmpty) {
    }
    if (options.headers.isNotEmpty) {
      options.headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization' && value.toString().length > 20) {
        } else {
        }
      });
    }
    if (options.data != null) {
      try {
        final prettyBody = JsonEncoder.withIndent('  ').convert(options.data);
      } catch (e) {
      }
    }
  }

  void _logResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '⚠️';

    if (response.data != null) {
      try {
        final prettyBody = JsonEncoder.withIndent('  ').convert(response.data);
      } catch (e) {
      }
    }
  }

  void _logError(DioException error) {
    if (error.response != null) {
      if (error.response?.data != null) {
        try {
          final prettyBody = JsonEncoder.withIndent('  ').convert(error.response?.data);
        } catch (e) {
        }
      }
    }
  }

  Dio get dio => _dio;

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>?> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return null;

      final response = await _dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {}, // 헤더에서 Authorization 제거
        ),
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        await saveTokens(accessToken, newRefreshToken);
        return response.data;
      }
    } catch (e) {
      // 리프레시 실패 시 토큰 삭제
      await deleteToken();
    }
    return null;
  }
}
