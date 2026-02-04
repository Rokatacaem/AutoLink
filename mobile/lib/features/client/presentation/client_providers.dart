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
      "health_score": 85,
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/Toyota_Supra_MK4_-_Flickr_-_Alexandre_Pr%C3%A9vot_%282%29_%28cropped%29.jpg/1200px-Toyota_Supra_MK4_-_Flickr_-_Alexandre_Pr%C3%A9vot_%282%29_%28cropped%29.jpg"
    },
    {
      "id": 2,
      "brand": "Ford",
      "model": "Mustang",
      "year": 1969,
      "vin": "1F02R100001",
      "health_score": 62,
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/4/4f/1969_Ford_Mustang_Boss_429_Fastback.jpg"
    },
    {
      "id": 3,
      "brand": "Nissan",
      "model": "GTR R34",
      "year": 2002,
      "vin": "BNR34-400123",
      "health_score": 98,
      "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Nissan_Skyline_GT-R_B-NR34_V-Spec_II_Nur_-_01.jpg/1200px-Nissan_Skyline_GT-R_B-NR34_V-Spec_II_Nur_-_01.jpg"
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
