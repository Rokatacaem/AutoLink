
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'client_providers.dart';

class MechanicListScreen extends ConsumerWidget {
  const MechanicListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mechanicsAsync = ref.watch(mechanicsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Find a Mechanic")),
      body: mechanicsAsync.when(
        data: (mechanics) {
          if (mechanics.isEmpty) {
            return const Center(child: Text("No mechanics found in your area."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mechanics.length,
            itemBuilder: (context, index) {
              final m = mechanics[index];
              final owner = m['owner'] ?? {}; 
              // 'owner' dict might be present if the serializer includes user data. 
              // Based on schemas/Mechanic.py, check if user relation is eager loaded? 
              // Checking endpoints/mechanics.py, it calls crud.mechanic.get_multi.
              // We assume backend returns basic info. Ideally we need mechanic name.
              
              final name = owner['full_name'] ?? 'Mechanic #${m['id']}';
              final address = m['address'] ?? 'No address';
              
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.build)),
                  title: Text(name),
                  subtitle: Text("$address\nSpecialty: ${m['specialty'] ?? 'General'}"),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: () {
                      context.push('/book-appointment?mechanicId=${m['id']}&name=$name');
                    },
                    child: const Text("Book"),
                  ),
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
