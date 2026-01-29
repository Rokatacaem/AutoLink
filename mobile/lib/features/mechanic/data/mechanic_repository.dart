import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../../auth/data/auth_repository.dart';

final mechanicRepositoryProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return MechanicRepository(dio, ref);
});

class MechanicRepository {
  final Dio _dio;
  final Ref _ref;

  MechanicRepository(this._dio, this._ref);

  Future<List<dynamic>> getReceivedRequests() async {
    try {
      final token = await _ref.read(authRepositoryProvider).getToken();
      final response = await _dio.get(
        '/services/received',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? 'Failed to load requests';
    }
  }

  Future<void> updateStatus(int requestId, String status) async {
    try {
      final token = await _ref.read(authRepositoryProvider).getToken();
      await _dio.patch(
        '/services/$requestId/status',
        queryParameters: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? 'Failed to update status';
    }
  }
}
