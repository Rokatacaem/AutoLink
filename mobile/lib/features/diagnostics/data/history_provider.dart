import 'package:autolink_mobile/features/client/presentation/selected_vehicle_provider.dart';
import 'package:autolink_mobile/features/diagnostics/domain/health_history_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final vehicleHistoryProvider = FutureProvider<List<HealthHistoryRecord>>((ref) async {
  final selectedVehicle = ref.watch(selectedVehicleProvider);
  
  if (selectedVehicle == null) return [];

  // Mock Data Simulation (Replace with API call later)
  await Future.delayed(const Duration(milliseconds: 800));

  return [
    HealthHistoryRecord(
      id: "1",
      timestamp: DateTime.now().subtract(const Duration(days: 0)),
      healthScore: 78,
      title: "Routine System Scan",
      description: "No critical issues found. Brake pads at 60%.",
      type: HealthEventType.scan,
    ),
    HealthHistoryRecord(
      id: "2",
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      healthScore: 82,
      title: "Maintenance Completed",
      description: "Oil change and filter replacement.",
      type: HealthEventType.maintenance,
    ),
    HealthHistoryRecord(
      id: "3",
      timestamp: DateTime.now().subtract(const Duration(days: 12)),
      healthScore: 65,
      title: "Engine Alert Resolved",
      description: "Misfire in Cylinder 3 detected and fixed.",
      type: HealthEventType.alert,
    ),
    HealthHistoryRecord(
      id: "4",
      timestamp: DateTime.now().subtract(const Duration(days: 30)),
      healthScore: 90,
      title: "Monthly Health Check",
      description: "Vehicle in optimal condition.",
      type: HealthEventType.scan,
    ),
  ];
});
