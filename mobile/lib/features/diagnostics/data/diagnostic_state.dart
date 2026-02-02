import 'dart:convert';
import 'package:autolink_mobile/features/diagnostics/domain/diagnostic_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'diagnostic_state.g.dart';

@Riverpod(keepAlive: true)
class LatestDiagnostic extends _$LatestDiagnostic {
  static const _key = 'latest_diagnostic_data';

  @override
  DiagnosticModel? build() {
    // Load initial state synchronously if possible, or trigger async load
    _loadFromPrefs();
    return null;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      try {
        final data = DiagnosticModel.fromJson(json.decode(jsonString));
        state = data;
      } catch (e) {
        // Handle corruption
      }
    }
  }

  Future<void> updateDiagnostic(DiagnosticModel match) async {
    state = match;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, json.encode(match.toJson()));
  }
}
