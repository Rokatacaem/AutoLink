import 'package:autolink_mobile/features/client/domain/vehicle.dart';
import 'package:autolink_mobile/features/client/presentation/client_providers.dart';
import 'package:autolink_mobile/features/diagnostics/data/diagnostic_repository.dart';
import 'package:autolink_mobile/features/diagnostics/data/diagnostic_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tracks the selected vehicle index or ID
final selectedVehicleIndexProvider = StateProvider<int>((ref) => 0);

// Provides the actual selected Vehicle object
final selectedVehicleProvider = Provider<Vehicle?>((ref) {
  final vehiclesState = ref.watch(myVehiclesProvider);
  final selectedIndex = ref.watch(selectedVehicleIndexProvider);

  return vehiclesState.when(
    data: (vehicles) {
      if (vehicles.isEmpty) return null;
      if (selectedIndex >= vehicles.length) return vehicles.first;
      return vehicles[selectedIndex];
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Logic to update diagnostics when vehicle changes
final vehicleSelectionLogicProvider = Provider((ref) {
  ref.listen(selectedVehicleProvider, (previous, next) {
    if (next != null) {
      // When selected vehicle changes, we could trigger a fresh diagnostic fetch
      // or simply clear the current diagnostic state if we don't have cached data for this car.
      // For now, let's just ensure we are ready to diagnose this new vehicle.
      
      // Optionally reset diagnostic state to null to avoid showing previous car's data
      // ref.read(latestDiagnosticProvider.notifier).updateDiagnostic(null); 
    }
  });
});
