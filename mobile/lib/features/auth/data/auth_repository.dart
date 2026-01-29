import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api_client.dart';

final authRepositoryProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return AuthRepository(dio, FlutterSecureStorage());
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': email,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      
      final token = response.data['access_token'];
      await _storage.write(key: 'auth_token', value: token);
      return token;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final detail = data['detail'];
        if (detail is List) {
           throw detail.map((item) => item['msg'] ?? item).join('\n');
        }
        throw detail ?? 'Login failed: ${e.message}';
      }
      if (data is String) {
        throw 'Server Error (${e.response?.statusCode}): $data';
      }
      throw 'Login failed: ${e.message}';
    }
  }

  Future<void> register(String email, String password, String fullName, String role) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'role': role, // "client" or "mechanic"
        },
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        // Handle Validation Errors (List of errors) or Simple Error (String)
        final detail = data['detail'];
        if (detail is List) {
           throw detail.map((e) => e['msg']).join('\n');
        }
        throw detail ?? 'Registration failed: ${e.message}';
      }
      // Handle HTML/String responses (Platform/Server errors)
      if (data is String) {
        throw 'Server Error (${e.response?.statusCode}): $data';
      }
      throw 'Registration failed: ${e.message}';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
