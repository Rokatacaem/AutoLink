import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/mechanic_repository.dart';

part 'mechanic_providers.g.dart';

@riverpod
class ServiceRequests extends _$ServiceRequests {
  @override
  FutureOr<List<dynamic>> build() async {
    return ref.read(mechanicRepositoryProvider).getReceivedRequests();
  }

  Future<void> updateStatus(int id, String status) async {
    await ref.read(mechanicRepositoryProvider).updateStatus(id, status);
    // Refresh list to show updated status
    ref.invalidateSelf(); 
  }
}
