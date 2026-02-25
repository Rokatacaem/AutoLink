import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnostic_model.freezed.dart';
part 'diagnostic_model.g.dart';

@freezed
class DiagnosticModel with _$DiagnosticModel {
  const factory DiagnosticModel({
    @JsonKey(name: 'diagnosis_summary') required String diagnosisSummary,
    @JsonKey(name: 'safety_protocol', defaultValue: []) required List<String> safetyProtocol,
    @JsonKey(name: 'prevention_tips', defaultValue: []) required List<String> preventionTips,
    @JsonKey(name: 'gravity_level', defaultValue: 'Low') required String gravityLevel,
    @JsonKey(name: 'technical_details') required String technicalDetails,
    @JsonKey(name: 'suggested_parts') required List<String> suggestedParts,
    @JsonKey(name: 'estimated_labor_hours') required double estimatedLaborHours,
    @JsonKey(name: 'required_specialty') required String requiredSpecialty,
  }) = _DiagnosticModel;

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) => _$DiagnosticModelFromJson(json);
}
