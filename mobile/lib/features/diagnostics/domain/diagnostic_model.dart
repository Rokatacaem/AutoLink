import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnostic_model.freezed.dart';
part 'diagnostic_model.g.dart';

@JsonEnum(alwaysCreate: true)
enum UrgencyLevel {
  @JsonValue('Low') low,
  @JsonValue('Medium') medium,
  @JsonValue('High') high,
  @JsonValue('Critical') critical,
}

@freezed
class Fault with _$Fault {
  const factory Fault({
    required String issue,
    required UrgencyLevel severity,
    String? description,
  }) = _Fault;

  factory Fault.fromJson(Map<String, dynamic> json) => _$FaultFromJson(json);
}

@freezed
class DiagnosticModel with _$DiagnosticModel {
  const factory DiagnosticModel({
    @JsonKey(name: 'health_score') required int healthScore,
    @JsonKey(name: 'urgency_level') required UrgencyLevel urgencyLevel,
    required List<Fault> faults,
    @JsonKey(name: 'recommended_actions') required List<String> recommendedActions,
  }) = _DiagnosticModel;

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) => _$DiagnosticModelFromJson(json);
}
