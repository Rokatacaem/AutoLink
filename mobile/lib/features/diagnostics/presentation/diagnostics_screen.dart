import 'package:autolink_mobile/features/diagnostics/data/diagnostic_repository.dart';
import 'package:autolink_mobile/features/diagnostics/data/maintenance_repository.dart';
import 'package:autolink_mobile/features/diagnostics/presentation/health_report_widget.dart';
import 'package:autolink_mobile/features/diagnostics/data/diagnostic_state.dart';
import 'package:autolink_mobile/features/diagnostics/domain/diagnostic_model.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DiagnosticsScreen extends ConsumerStatefulWidget {
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
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  DiagnosticModel? _activeModel;

  @override
  Widget build(BuildContext context) {
    final diagnosticAsync = ref.watch(diagnosticReportProvider(
      description: widget.description,
      vehicleId: widget.vehicleId,
      locale: widget.locale,
    ));

    ref.listen(diagnosticReportProvider(
      description: widget.description,
      vehicleId: widget.vehicleId,
      locale: widget.locale,
    ), (prev, next) {
      if (next.hasValue && next.value != null && _activeModel == null) {
          setState(() {
            _activeModel = next.value;
          });
          // Sync global state on initial load
          Future.microtask(() {
             ref.read(latestDiagnosticProvider.notifier).updateDiagnostic(next.value!);
             bool isCritical = next.value!.gravityLevel.toUpperCase() == 'CRITICAL';
             if (next.value!.safetyProtocol.isNotEmpty || isCritical) {
                 _showSafetyProtocolModal(next.value!);
             }
          });
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
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
            // Main Content
            if (_activeModel != null)
                 HealthReportWidget(
                     data: _activeModel!,
                 )
            else
                diagnosticAsync.when(
                    data: (data) {
                        if (_activeModel == null) {
                             Future.microtask(() {
                                 if (mounted && _activeModel == null) {
                                     setState(() { _activeModel = data; });
                                      ref.read(latestDiagnosticProvider.notifier).updateDiagnostic(data);
                                 }
                             });
                        }
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))); 
                    },
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
                                description: widget.description,
                                vehicleId: widget.vehicleId,
                                locale: widget.locale,
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
            
        ],
      ),
    );
  }

  void _showSafetyProtocolModal(DiagnosticModel model) {
    bool isCritical = model.gravityLevel.toUpperCase() == 'CRITICAL';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        if (isCritical) {
          // FULL SCREEN EMERGENCY OVERLAY
          return Dialog.fullscreen(
            backgroundColor: const Color(0xFF0A0000),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 80),
                    const SizedBox(height: 16),
                    Text(
                      "EMERGENCIA CRÍTICA",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 28),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "El análisis ha detectado un riesgo vital inminente. Por favor, ejecuta INMEDIATAMENTE los siguientes pasos antes de solicitar rescate mecánico:",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: ListView(
                        children: [
                          ...model.safetyProtocol.map((step) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("🚨 ", style: TextStyle(fontSize: 24)),
                                    Expanded(child: Text(step, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, height: 1.4, fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              )),
                          if (model.preventionTips.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(color: Colors.redAccent),
                              const SizedBox(height: 16),
                              Text("PREVENCIÓN CRÍTICA (No hacer):", style: GoogleFonts.outfit(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 12),
                              ...model.preventionTips.map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("❌ ", style: TextStyle(fontSize: 18)),
                                    Expanded(child: Text(tip, style: GoogleFonts.outfit(color: Colors.orange[200], fontSize: 16, height: 1.4))),
                                  ],
                                ),
                              )),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () { /* LLAMAR A EMERGENCIAS */ },
                      icon: const Icon(Icons.emergency, color: Colors.white, size: 28),
                      label: Text("LLAMAR A URGENCIAS PÚBLICAS (133)", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("HE ASEGURADO LA ZONA (CERRAR)", style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                    )
                  ],
                ),
              ),
            ),
          );
        }

        // STANDARD ALERT DIALOG
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(16),
             side: const BorderSide(color: Colors.orangeAccent, width: 2)
          ),
          title: Row(
            children: [
              const Icon(Icons.health_and_safety_rounded, color: Colors.orangeAccent, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Protocolo de Seguridad",
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              )
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AutoLink Safety Advisor recomienda las siguientes acciones inmediatas:",
                style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 16),
              ...model.safetyProtocol.map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("🚨 ", style: TextStyle(fontSize: 16)),
                        Expanded(child: Text(step, style: GoogleFonts.outfit(color: Colors.white, height: 1.4))),
                      ],
                    ),
                  )),
              if (model.preventionTips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 12),
                  Text("PREVENCIÓN (No hacer):", style: GoogleFonts.outfit(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  ...model.preventionTips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("❌ ", style: TextStyle(fontSize: 14)),
                        Expanded(child: Text(tip, style: GoogleFonts.outfit(color: Colors.grey[300], fontSize: 13, height: 1.4))),
                      ],
                    ),
                  )),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("ENTENDIDO", style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    );
  }
}
