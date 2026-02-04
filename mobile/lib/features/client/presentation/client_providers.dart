import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/data/auth_repository.dart';
import '../data/client_repository.dart';
import '../domain/vehicle.dart';

part 'client_providers.g.dart';

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
  final token = await ref.watch(authRepositoryProvider).getToken();

  // Mock Data for Mechanics
  final mockMechanics = [
    {
      "id": 101,
      "full_name": "Dr. Motor",
      "specialty": "Engine Specialist",
      "rating": 4.8,
      "distance": "2.5 km"
    },
    {
      "id": 102,
      "full_name": "Suspigod",
      "specialty": "Suspension & Brakes",
      "rating": 4.9,
      "distance": "4.1 km"
    },
    {
      "id": 103,
      "full_name": "ElecTrick",
      "specialty": "Electronics",
      "rating": 4.5,
      "distance": "1.2 km"
    }
  ];

  if (token == null || token.isEmpty) {
    return mockMechanics;
  }

  try {
    return await ref.watch(clientRepositoryProvider).getMechanics();
  } catch (e) {
    return mockMechanics;
  }
}
