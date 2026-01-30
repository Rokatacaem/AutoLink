import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/client_repository.dart';

part 'client_providers.g.dart';

@riverpod
Future<List<dynamic>> myVehicles(MyVehiclesRef ref) async {
  return ref.watch(clientRepositoryProvider).getMyVehicles();
}
@riverpod
Future<List<dynamic>> mechanicsList(MechanicsListRef ref) async {
  return ref.watch(clientRepositoryProvider).getMechanics();
}
