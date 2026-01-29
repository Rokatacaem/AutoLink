import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider((ref) => ApiClient());

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://auto-link-steel.vercel.app/api/v1', // Vercel Cloud Production
        // baseUrl: 'http://192.168.1.27:8000/api/v1', // Local LAN IP
        // baseUrl: 'http://10.0.2.2:8000/api/v1', // Android Emulator
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print("API LOG: $obj"),
    ));
  }
}
