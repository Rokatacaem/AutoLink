import 'package:autolink_mobile/core/api_client.dart';
import 'package:autolink_mobile/features/diagnostics/domain/diagnostic_model.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'diagnostic_repository.g.dart';

@riverpod
DiagnosticRepository diagnosticRepository(DiagnosticRepositoryRef ref) {
  return DiagnosticRepository(ref.watch(apiClientProvider).dio);
}

@riverpod
Future<DiagnosticModel> diagnosticReport(
  DiagnosticReportRef ref, {
  required String description,
  int? vehicleId,
  String locale = 'es_CL',
  bool autoDraftRequest = false,
}) {
  return ref.watch(diagnosticRepositoryProvider).getDiagnosticReport(
        description: description,
        vehicleId: vehicleId,
        locale: locale,
        autoDraftRequest: autoDraftRequest,
      );
}

class DiagnosticRepository {
  final Dio _dio;

  DiagnosticRepository(this._dio);

  Future<DiagnosticModel> getDiagnosticReport({
    required String description,
    int? vehicleId,
    String? locale,
    bool autoDraftRequest = false,
  }) async {
    try {
      final response = await _dio.post(
        '/ai/diagnose',
        data: {
          'description': description,
          if (vehicleId != null) 'vehicle_id': vehicleId,
          if (locale != null) 'locale': locale,
          'auto_draft_request': autoDraftRequest,
        },
      );

      return DiagnosticModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
