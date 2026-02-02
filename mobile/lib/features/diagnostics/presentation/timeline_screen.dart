import 'package:autolink_mobile/features/diagnostics/data/history_provider.dart';
import 'package:autolink_mobile/features/diagnostics/presentation/timeline_chart.dart';
import 'package:autolink_mobile/features/diagnostics/presentation/timeline_event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class HealthTimelineScreen extends ConsumerWidget {
  const HealthTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(vehicleHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("HEALTH TIMELINE", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Chart
            const TimelineChart(),
            
            const SizedBox(height: 30),
            
            // Timeline Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "HISTORY LOG",
                style: GoogleFonts.outfit(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),
             const SizedBox(height: 16),

            // Vertical List
            Expanded(
              child: historyAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return Center(child: Text("No history available", style: GoogleFonts.outfit(color: Colors.grey)));
                  }
                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      return TimelineEventCard(
                        record: records[index],
                        isLast: index == records.length - 1,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
                error: (err, stack) => Center(child: Text("Error loading history: $err", style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
