import 'package:autolink_mobile/core/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenanceRepository {
  final Dio _dio;

  MaintenanceRepository(this._dio);

  Future<void> submitMaintenanceAction({
    required int vehicleId,
    required String description,
    required String actionTaken,
    required int scoreImpact,
  }) async {
    try {
      await _dio.post(
        '/vehicles/$vehicleId/maintenance',
        data: {
          'description': description,
          'action_taken': actionTaken,
          'score_impact': scoreImpact,
        },
      );
    } catch (e) {
      // In a real app we might want to queue this offline
      throw Exception('Failed to submit maintenance: $e');
    }
  }
}

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return MaintenanceRepository(dio);
});
