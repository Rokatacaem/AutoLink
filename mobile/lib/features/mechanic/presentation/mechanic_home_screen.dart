import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mechanic_providers.dart';
import 'service_request_card.dart';

class MechanicHomeScreen extends ConsumerWidget {
  const MechanicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(serviceRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mechanic Inbox"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(serviceRequestsProvider),
          ),
        ],
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) return const Center(child: Text("No requests yet."));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return ServiceRequestCard(
                request: req,
                onStatusUpdate: (newStatus) {
                  ref.read(serviceRequestsProvider.notifier).updateStatus(req['id'], newStatus);
                },
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
