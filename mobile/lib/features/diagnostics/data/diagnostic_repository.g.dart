// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diagnosticRepositoryHash() =>
    r'080484ad27be3438ca8b7e58b38e52452cd469c2';

/// See also [diagnosticRepository].
@ProviderFor(diagnosticRepository)
final diagnosticRepositoryProvider =
    AutoDisposeProvider<DiagnosticRepository>.internal(
  diagnosticRepository,
  name: r'diagnosticRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diagnosticRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DiagnosticRepositoryRef = AutoDisposeProviderRef<DiagnosticRepository>;
String _$diagnosticReportHash() => r'6995ad719646499507abf8343a7600183a015683';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [diagnosticReport].
@ProviderFor(diagnosticReport)
const diagnosticReportProvider = DiagnosticReportFamily();

/// See also [diagnosticReport].
class DiagnosticReportFamily extends Family<AsyncValue<DiagnosticModel>> {
  /// See also [diagnosticReport].
  const DiagnosticReportFamily();

  /// See also [diagnosticReport].
  DiagnosticReportProvider call({
    required String description,
    int? vehicleId,
    String locale = 'es_CL',
  }) {
    return DiagnosticReportProvider(
      description: description,
      vehicleId: vehicleId,
      locale: locale,
    );
  }

  @override
  DiagnosticReportProvider getProviderOverride(
    covariant DiagnosticReportProvider provider,
  ) {
    return call(
      description: provider.description,
      vehicleId: provider.vehicleId,
      locale: provider.locale,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'diagnosticReportProvider';
}

/// See also [diagnosticReport].
class DiagnosticReportProvider
    extends AutoDisposeFutureProvider<DiagnosticModel> {
  /// See also [diagnosticReport].
  DiagnosticReportProvider({
    required String description,
    int? vehicleId,
    String locale = 'es_CL',
  }) : this._internal(
          (ref) => diagnosticReport(
            ref as DiagnosticReportRef,
            description: description,
            vehicleId: vehicleId,
            locale: locale,
          ),
          from: diagnosticReportProvider,
          name: r'diagnosticReportProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$diagnosticReportHash,
          dependencies: DiagnosticReportFamily._dependencies,
          allTransitiveDependencies:
              DiagnosticReportFamily._allTransitiveDependencies,
          description: description,
          vehicleId: vehicleId,
          locale: locale,
        );

  DiagnosticReportProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.description,
    required this.vehicleId,
    required this.locale,
  }) : super.internal();

  final String description;
  final int? vehicleId;
  final String locale;

  @override
  Override overrideWith(
    FutureOr<DiagnosticModel> Function(DiagnosticReportRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DiagnosticReportProvider._internal(
        (ref) => create(ref as DiagnosticReportRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        description: description,
        vehicleId: vehicleId,
        locale: locale,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DiagnosticModel> createElement() {
    return _DiagnosticReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DiagnosticReportProvider &&
        other.description == description &&
        other.vehicleId == vehicleId &&
        other.locale == locale;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, description.hashCode);
    hash = _SystemHash.combine(hash, vehicleId.hashCode);
    hash = _SystemHash.combine(hash, locale.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DiagnosticReportRef on AutoDisposeFutureProviderRef<DiagnosticModel> {
  /// The parameter `description` of this provider.
  String get description;

  /// The parameter `vehicleId` of this provider.
  int? get vehicleId;

  /// The parameter `locale` of this provider.
  String get locale;
}

class _DiagnosticReportProviderElement
    extends AutoDisposeFutureProviderElement<DiagnosticModel>
    with DiagnosticReportRef {
  _DiagnosticReportProviderElement(super.provider);

  @override
  String get description => (origin as DiagnosticReportProvider).description;
  @override
  int? get vehicleId => (origin as DiagnosticReportProvider).vehicleId;
  @override
  String get locale => (origin as DiagnosticReportProvider).locale;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
