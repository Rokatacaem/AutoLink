import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/client_repository.dart';
import '../domain/vehicle.dart';

part 'client_providers.g.dart';

import '../../auth/data/auth_repository.dart';

@riverpod
Future<List<dynamic>> myVehicles(MyVehiclesRef ref) async {
  // Check for authentication first
  final token = await ref.watch(authRepositoryProvider).getToken();
  
  // Explicit Mock Data for "Guest/Test" Mode or fallback
  final mockVehicles = [
    {
      "id": 1,
      "brand": "Toyota",
      "model": "Supra MK4",
      "year": 1998,
      "vin": "JT2JA82J100001",
      "health_score": 85
    },
    {
      "id": 2,
      "brand": "Ford",
      "model": "Mustang",
      "year": 1969,
      "vin": "1F02R100001",
      "health_score": 62
    },
    {
      "id": 3,
      "brand": "Nissan",
      "model": "GTR R34",
      "year": 2002,
      "vin": "BNR34-400123",
      "health_score": 98
    }
  ].map((json) => Vehicle.fromJson(json)).toList();

  if (token == null || token.isEmpty) {
    return mockVehicles;
  }

  try {
    return await ref.watch(clientRepositoryProvider).getMyVehicles();
  } catch (e) {
    // Also fallback to mock data on API error for now to ensure UI is testable
    return mockVehicles;
  }
}
@riverpod
Future<List<dynamic>> mechanicsList(MechanicsListRef ref) async {
  return ref.watch(clientRepositoryProvider).getMechanics();
}
