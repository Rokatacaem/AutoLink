import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/client_repository.dart';

// Simple state provider for the diagnosis result
final diagnosisResultProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
final diagnosisLoadingProvider = StateProvider<bool>((ref) => false);

class AIChatScreen extends ConsumerStatefulWidget {
  final String? vehicleId;
  final String? vehicleName;

  const AIChatScreen({super.key, this.vehicleId, this.vehicleName});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final _descController = TextEditingController();

  Future<void> _analyze() async {
    if (_descController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Description too short")));
      return;
    }

    ref.read(diagnosisLoadingProvider.notifier).state = true;
    ref.read(diagnosisResultProvider.notifier).state = null;

    try {
      final repo = ref.read(clientRepositoryProvider);
      final result = await repo.diagnoseIssue(
        _descController.text, 
        widget.vehicleId != null ? int.parse(widget.vehicleId!) : null
      );
      ref.read(diagnosisResultProvider.notifier).state = result;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      ref.read(diagnosisLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(diagnosisResultProvider);
    final isLoading = ref.watch(diagnosisLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.vehicleName != null ? "Diagnose ${widget.vehicleName}" : "AI Diagnosis")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Describe the problem (symptoms, noises, etc.)",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: "e.g. squeaky brakes when stopping..."),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _analyze,
                icon: const Icon(Icons.auto_awesome),
                label: isLoading ? const Text("Analyzing...") : const Text("Analyze Issues"),
              ),
            ),
            const SizedBox(height: 30),
            if (result != null) ...[
              _buildResultCard(context, result),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, Map<String, dynamic> data) {
    Color severityColor = Colors.green;
    if (data['severity'] == 'MEDIUM') severityColor = Colors.orange;
    if (data['severity'] == 'HIGH' || data['severity'] == 'CRITICAL') severityColor = Colors.red;

    return Card(
      color: const Color(0xFF252525),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: severityColor, width: 2)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: severityColor),
                const SizedBox(width: 8),
                Text(
                  "SEVERITY: ${data['severity']}",
                  style: TextStyle(color: severityColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            Text(
              data['possible_cause'],
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Category: ${data['suggested_category']}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Text("Recommendation:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(data['recommendation']),
          ],
        ),
      ),
    );
  }
}
