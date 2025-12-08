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
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  void _logRequest(RequestOptions options) {
    print('\n╔═══════════════════════════════════════════════════════════════════════');
    print('║ 🚀 REQUEST');
    print('╠═══════════════════════════════════════════════════════════════════════');
    print('║ ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      print('║ Query: ${options.queryParameters}');
    }
    if (options.headers.isNotEmpty) {
      print('║ Headers:');
      options.headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization' && value.toString().length > 20) {
          print('║   $key: ${value.toString().substring(0, 20)}...');
        } else {
          print('║   $key: $value');
        }
      });
    }
    if (options.data != null) {
      print('║ Body:');
      try {
        final prettyBody = JsonEncoder.withIndent('  ').convert(options.data);
        prettyBody.split('\n').forEach((line) => print('║   $line'));
      } catch (e) {
        print('║   ${options.data}');
      }
    }
    print('╚═══════════════════════════════════════════════════════════════════════\n');
  }

  void _logResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '⚠️';

    print('\n╔═══════════════════════════════════════════════════════════════════════');
    print('║ $emoji RESPONSE [$statusCode]');
    print('╠═══════════════════════════════════════════════════════════════════════');
    print('║ ${response.requestOptions.method} ${response.requestOptions.uri}');
    print('║ Status: $statusCode');
    if (response.data != null) {
      print('║ Body:');
      try {
        final prettyBody = JsonEncoder.withIndent('  ').convert(response.data);
        prettyBody.split('\n').forEach((line) => print('║   $line'));
      } catch (e) {
        print('║   ${response.data}');
      }
    }
    print('╚═══════════════════════════════════════════════════════════════════════\n');
  }

  void _logError(DioException error) {
    print('\n╔═══════════════════════════════════════════════════════════════════════');
    print('║ ❌ ERROR');
    print('╠═══════════════════════════════════════════════════════════════════════');
    print('║ ${error.requestOptions.method} ${error.requestOptions.uri}');
    print('║ Type: ${error.type}');
    print('║ Message: ${error.message}');
    if (error.response != null) {
      print('║ Status: ${error.response?.statusCode}');
      if (error.response?.data != null) {
        print('║ Response:');
        try {
          final prettyBody = JsonEncoder.withIndent('  ').convert(error.response?.data);
          prettyBody.split('\n').forEach((line) => print('║   $line'));
        } catch (e) {
          print('║   ${error.response?.data}');
        }
      }
    }
    print('╚═══════════════════════════════════════════════════════════════════════\n');
  }

  Dio get dio => _dio;

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
