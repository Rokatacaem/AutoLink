// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostic_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Fault _$FaultFromJson(Map<String, dynamic> json) {
  return _Fault.fromJson(json);
}

/// @nodoc
mixin _$Fault {
  String get issue => throw _privateConstructorUsedError;
  UrgencyLevel get severity => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FaultCopyWith<Fault> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaultCopyWith<$Res> {
  factory $FaultCopyWith(Fault value, $Res Function(Fault) then) =
      _$FaultCopyWithImpl<$Res, Fault>;
  @useResult
  $Res call({String issue, UrgencyLevel severity, String? description});
}

/// @nodoc
class _$FaultCopyWithImpl<$Res, $Val extends Fault>
    implements $FaultCopyWith<$Res> {
  _$FaultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? issue = null,
    Object? severity = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      issue: null == issue
          ? _value.issue
          : issue // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as UrgencyLevel,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FaultImplCopyWith<$Res> implements $FaultCopyWith<$Res> {
  factory _$$FaultImplCopyWith(
          _$FaultImpl value, $Res Function(_$FaultImpl) then) =
      __$$FaultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String issue, UrgencyLevel severity, String? description});
}

/// @nodoc
class __$$FaultImplCopyWithImpl<$Res>
    extends _$FaultCopyWithImpl<$Res, _$FaultImpl>
    implements _$$FaultImplCopyWith<$Res> {
  __$$FaultImplCopyWithImpl(
      _$FaultImpl _value, $Res Function(_$FaultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? issue = null,
    Object? severity = null,
    Object? description = freezed,
  }) {
    return _then(_$FaultImpl(
      issue: null == issue
          ? _value.issue
          : issue // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as UrgencyLevel,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FaultImpl implements _Fault {
  const _$FaultImpl(
      {required this.issue, required this.severity, this.description});

  factory _$FaultImpl.fromJson(Map<String, dynamic> json) =>
      _$$FaultImplFromJson(json);

  @override
  final String issue;
  @override
  final UrgencyLevel severity;
  @override
  final String? description;

  @override
  String toString() {
    return 'Fault(issue: $issue, severity: $severity, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FaultImpl &&
            (identical(other.issue, issue) || other.issue == issue) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, issue, severity, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FaultImplCopyWith<_$FaultImpl> get copyWith =>
      __$$FaultImplCopyWithImpl<_$FaultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FaultImplToJson(
      this,
    );
  }
}

abstract class _Fault implements Fault {
  const factory _Fault(
      {required final String issue,
      required final UrgencyLevel severity,
      final String? description}) = _$FaultImpl;

  factory _Fault.fromJson(Map<String, dynamic> json) = _$FaultImpl.fromJson;

  @override
  String get issue;
  @override
  UrgencyLevel get severity;
  @override
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$FaultImplCopyWith<_$FaultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DiagnosticModel _$DiagnosticModelFromJson(Map<String, dynamic> json) {
  return _DiagnosticModel.fromJson(json);
}

/// @nodoc
mixin _$DiagnosticModel {
  @JsonKey(name: 'health_score')
  int get healthScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'urgency_level')
  UrgencyLevel get urgencyLevel => throw _privateConstructorUsedError;
  List<Fault> get faults => throw _privateConstructorUsedError;
  @JsonKey(name: 'recommended_actions')
  List<String> get recommendedActions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiagnosticModelCopyWith<DiagnosticModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiagnosticModelCopyWith<$Res> {
  factory $DiagnosticModelCopyWith(
          DiagnosticModel value, $Res Function(DiagnosticModel) then) =
      _$DiagnosticModelCopyWithImpl<$Res, DiagnosticModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'health_score') int healthScore,
      @JsonKey(name: 'urgency_level') UrgencyLevel urgencyLevel,
      List<Fault> faults,
      @JsonKey(name: 'recommended_actions') List<String> recommendedActions});
}

/// @nodoc
class _$DiagnosticModelCopyWithImpl<$Res, $Val extends DiagnosticModel>
    implements $DiagnosticModelCopyWith<$Res> {
  _$DiagnosticModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? healthScore = null,
    Object? urgencyLevel = null,
    Object? faults = null,
    Object? recommendedActions = null,
  }) {
    return _then(_value.copyWith(
      healthScore: null == healthScore
          ? _value.healthScore
          : healthScore // ignore: cast_nullable_to_non_nullable
              as int,
      urgencyLevel: null == urgencyLevel
          ? _value.urgencyLevel
          : urgencyLevel // ignore: cast_nullable_to_non_nullable
              as UrgencyLevel,
      faults: null == faults
          ? _value.faults
          : faults // ignore: cast_nullable_to_non_nullable
              as List<Fault>,
      recommendedActions: null == recommendedActions
          ? _value.recommendedActions
          : recommendedActions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiagnosticModelImplCopyWith<$Res>
    implements $DiagnosticModelCopyWith<$Res> {
  factory _$$DiagnosticModelImplCopyWith(_$DiagnosticModelImpl value,
          $Res Function(_$DiagnosticModelImpl) then) =
      __$$DiagnosticModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'health_score') int healthScore,
      @JsonKey(name: 'urgency_level') UrgencyLevel urgencyLevel,
      List<Fault> faults,
      @JsonKey(name: 'recommended_actions') List<String> recommendedActions});
}

/// @nodoc
class __$$DiagnosticModelImplCopyWithImpl<$Res>
    extends _$DiagnosticModelCopyWithImpl<$Res, _$DiagnosticModelImpl>
    implements _$$DiagnosticModelImplCopyWith<$Res> {
  __$$DiagnosticModelImplCopyWithImpl(
      _$DiagnosticModelImpl _value, $Res Function(_$DiagnosticModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? healthScore = null,
    Object? urgencyLevel = null,
    Object? faults = null,
    Object? recommendedActions = null,
  }) {
    return _then(_$DiagnosticModelImpl(
      healthScore: null == healthScore
          ? _value.healthScore
          : healthScore // ignore: cast_nullable_to_non_nullable
              as int,
      urgencyLevel: null == urgencyLevel
          ? _value.urgencyLevel
          : urgencyLevel // ignore: cast_nullable_to_non_nullable
              as UrgencyLevel,
      faults: null == faults
          ? _value._faults
          : faults // ignore: cast_nullable_to_non_nullable
              as List<Fault>,
      recommendedActions: null == recommendedActions
          ? _value._recommendedActions
          : recommendedActions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiagnosticModelImpl implements _DiagnosticModel {
  const _$DiagnosticModelImpl(
      {@JsonKey(name: 'health_score') required this.healthScore,
      @JsonKey(name: 'urgency_level') required this.urgencyLevel,
      required final List<Fault> faults,
      @JsonKey(name: 'recommended_actions')
      required final List<String> recommendedActions})
      : _faults = faults,
        _recommendedActions = recommendedActions;

  factory _$DiagnosticModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiagnosticModelImplFromJson(json);

  @override
  @JsonKey(name: 'health_score')
  final int healthScore;
  @override
  @JsonKey(name: 'urgency_level')
  final UrgencyLevel urgencyLevel;
  final List<Fault> _faults;
  @override
  List<Fault> get faults {
    if (_faults is EqualUnmodifiableListView) return _faults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_faults);
  }

  final List<String> _recommendedActions;
  @override
  @JsonKey(name: 'recommended_actions')
  List<String> get recommendedActions {
    if (_recommendedActions is EqualUnmodifiableListView)
      return _recommendedActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendedActions);
  }

  @override
  String toString() {
    return 'DiagnosticModel(healthScore: $healthScore, urgencyLevel: $urgencyLevel, faults: $faults, recommendedActions: $recommendedActions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiagnosticModelImpl &&
            (identical(other.healthScore, healthScore) ||
                other.healthScore == healthScore) &&
            (identical(other.urgencyLevel, urgencyLevel) ||
                other.urgencyLevel == urgencyLevel) &&
            const DeepCollectionEquality().equals(other._faults, _faults) &&
            const DeepCollectionEquality()
                .equals(other._recommendedActions, _recommendedActions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      healthScore,
      urgencyLevel,
      const DeepCollectionEquality().hash(_faults),
      const DeepCollectionEquality().hash(_recommendedActions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiagnosticModelImplCopyWith<_$DiagnosticModelImpl> get copyWith =>
      __$$DiagnosticModelImplCopyWithImpl<_$DiagnosticModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiagnosticModelImplToJson(
      this,
    );
  }
}

abstract class _DiagnosticModel implements DiagnosticModel {
  const factory _DiagnosticModel(
      {@JsonKey(name: 'health_score') required final int healthScore,
      @JsonKey(name: 'urgency_level') required final UrgencyLevel urgencyLevel,
      required final List<Fault> faults,
      @JsonKey(name: 'recommended_actions')
      required final List<String> recommendedActions}) = _$DiagnosticModelImpl;

  factory _DiagnosticModel.fromJson(Map<String, dynamic> json) =
      _$DiagnosticModelImpl.fromJson;

  @override
  @JsonKey(name: 'health_score')
  int get healthScore;
  @override
  @JsonKey(name: 'urgency_level')
  UrgencyLevel get urgencyLevel;
  @override
  List<Fault> get faults;
  @override
  @JsonKey(name: 'recommended_actions')
  List<String> get recommendedActions;
  @override
  @JsonKey(ignore: true)
  _$$DiagnosticModelImplCopyWith<_$DiagnosticModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
