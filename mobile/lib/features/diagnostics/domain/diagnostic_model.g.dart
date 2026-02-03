// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FaultImpl _$$FaultImplFromJson(Map<String, dynamic> json) => _$FaultImpl(
      issue: json['issue'] as String,
      severity: $enumDecode(_$UrgencyLevelEnumMap, json['severity']),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$FaultImplToJson(_$FaultImpl instance) =>
    <String, dynamic>{
      'issue': instance.issue,
      'severity': _$UrgencyLevelEnumMap[instance.severity]!,
      'description': instance.description,
    };

const _$UrgencyLevelEnumMap = {
  UrgencyLevel.low: 'Low',
  UrgencyLevel.medium: 'Medium',
  UrgencyLevel.high: 'High',
  UrgencyLevel.critical: 'Critical',
};

_$DiagnosticModelImpl _$$DiagnosticModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DiagnosticModelImpl(
      healthScore: (json['health_score'] as num).toInt(),
      urgencyLevel: $enumDecode(_$UrgencyLevelEnumMap, json['urgency_level']),
      faults: (json['faults'] as List<dynamic>)
          .map((e) => Fault.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedActions: (json['recommended_actions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$DiagnosticModelImplToJson(
        _$DiagnosticModelImpl instance) =>
    <String, dynamic>{
      'health_score': instance.healthScore,
      'urgency_level': _$UrgencyLevelEnumMap[instance.urgencyLevel]!,
      'faults': instance.faults,
      'recommended_actions': instance.recommendedActions,
    };
