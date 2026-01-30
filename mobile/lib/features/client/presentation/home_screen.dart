import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'client_providers.dart';
import 'vehicle_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(myVehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Garage"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/mechanic-list'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/add-vehicle'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(myVehiclesProvider),
          ),
        ],
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No vehicles found."),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/add-vehicle'),
                    icon: const Icon(Icons.add),
                    label: const Text("Add One"),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final v = vehicles[index];
              return VehicleCard(
                vehicle: v, 
                onTap: () {
                   // Navigate to diagnosis with pre-selected vehicle
                   context.push('/diagnosis?vehicleId=${v['id']}&name=${v['brand']} ${v['model']}');
                }
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/diagnosis'),
        label: const Text("AI Diagnose"),
        icon: const Icon(Icons.health_and_safety),
      ),
    );
  }
}
