import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mechanic_providers.dart';
import 'service_request_card.dart';

class MechanicHomeScreen extends ConsumerWidget {
  const MechanicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(serviceRequestsProvider);

    return kIsWeb 
        ? _buildScaffold(context, ref, requestsAsync) 
        : DefaultTabController(length: 3, child: _buildScaffold(context, ref, requestsAsync));
  }

  Widget _buildScaffold(BuildContext context, WidgetRef ref, AsyncValue<List<dynamic>> requestsAsync) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mechanic Inbox"),
        bottom: const TabBar(
          tabs: [
            Tab(text: "Pending", icon: Icon(Icons.new_releases)),
            Tab(text: "Active", icon: Icon(Icons.build)),
            Tab(text: "History", icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(serviceRequestsProvider),
          ),
        ],
      ),
      body: requestsAsync.when(
        data: (requests) {
          final pending = requests.where((r) => r['status'] == 'PENDING').toList();
          final active = requests.where((r) => r['status'] == 'ACCEPTED' || r['status'] == 'QUOTED').toList();
          final history = requests.where((r) => 
            r['status'] == 'COMPLETED' || r['status'] == 'REJECTED' || r['status'] == 'CANCELED'
          ).toList();

          return TabBarView(
            children: [
              _buildList(ref, pending, "No new requests."),
              _buildList(ref, active, "No active jobs."),
              _buildList(ref, history, "No history yet."),
            ],
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildList(WidgetRef ref, List<dynamic> items, String emptyMsg) {
    if (items.isEmpty) return Center(child: Text(emptyMsg));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final req = items[index];
        return ServiceRequestCard(
          request: req,
          onStatusUpdate: (newStatus) {
            ref.read(serviceRequestsProvider.notifier).updateStatus(req['id'], newStatus);
          },
        );
      },
    );
  }
}
