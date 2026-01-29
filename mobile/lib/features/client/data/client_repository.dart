import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../../auth/data/auth_repository.dart';

final clientRepositoryProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return ClientRepository(dio, ref);
});

class ClientRepository {
  final Dio _dio;
  final Ref _ref;

  ClientRepository(this._dio, this._ref);

  Future<List<dynamic>> getMyVehicles() async {
    try {
      final token = await _ref.read(authRepositoryProvider).getToken();
      final response = await _dio.get(
        '/vehicles/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? 'Failed to load vehicles';
    }
  }

  Future<Map<String, dynamic>> diagnoseIssue(String description, int? vehicleId) async {
    try {
      final token = await _ref.read(authRepositoryProvider).getToken();
      final response = await _dio.post(
        '/ai/diagnose',
        data: {
          'description': description,
          'vehicle_id': vehicleId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? 'Diagnosis failed';
    }
  }
}
