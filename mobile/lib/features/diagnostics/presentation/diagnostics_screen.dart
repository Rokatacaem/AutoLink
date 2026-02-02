import 'package:autolink_mobile/features/diagnostics/data/diagnostic_repository.dart';
import 'package:autolink_mobile/features/diagnostics/presentation/health_report_widget.dart';
import 'package:autolink_mobile/features/diagnostics/data/diagnostic_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DiagnosticsScreen extends ConsumerWidget {
  final String description;
  final int? vehicleId;
  final String locale;

  const DiagnosticsScreen({
    super.key,
    required this.description,
    this.vehicleId,
    this.locale = 'es_CL',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the FutureProvider. 
    // This triggers the API call immediately when the screen is built.
    final diagnosticAsync = ref.watch(diagnosticReportProvider(
      description: description,
      vehicleId: vehicleId,
      locale: locale,
    ));

    // Update global state on successful load so Panic Button can react
    ref.listen(diagnosticReportProvider(
      description: description,
      vehicleId: vehicleId,
      locale: locale,
    ), (previous, next) {
      if (next.hasValue && next.value != null) {
         // Using future microtask to avoid build conflicts
         Future.microtask(() => 
            ref.read(latestDiagnosticProvider.notifier).updateDiagnostic(next.value!)
         );
      }
    });


    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'AI DIAGNOSIS', 
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: diagnosticAsync.when(
        data: (data) => HealthReportWidget(data: data),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const CircularProgressIndicator(color: Color(0xFF00E5FF)),
               const SizedBox(height: 20),
               Text(
                 "Analyzing vehicle data...",
                 style: GoogleFonts.outfit(color: Colors.grey, letterSpacing: 1.2),
               )
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 20),
                Text(
                  "Diagnosis Unavailable",
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Ensure you are connected to the server and try again.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.grey[600]),
                ),
                 const SizedBox(height: 30),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(diagnosticReportProvider(
                    description: description,
                    vehicleId: vehicleId,
                    locale: locale,
                  )),
                  icon: const Icon(Icons.refresh, color: Color(0xFF00E5FF)),
                  label: Text("Retry Analysis", style: GoogleFonts.outfit(color: const Color(0xFF00E5FF))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00E5FF)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
