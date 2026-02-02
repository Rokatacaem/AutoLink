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
  late ConfettiController _confettiController;
  DiagnosticModel? _activeModel;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _handleResolve(Fault fault) async {
    if (widget.vehicleId == null || _activeModel == null) return;

    // Optimistic Update
    final currentModel = _activeModel!;
    final impact = _calculateImpact(fault.severity);
    int newScore = (currentModel.healthScore + impact).clamp(0, 100);
    
    // Level Up Check
    if (currentModel.healthScore < 100 && newScore == 100) {
      _confettiController.play();
    }

    final updatedModel = currentModel.copyWith(
      healthScore: newScore,
      faults: currentModel.faults.where((f) => f != fault).toList(),
      urgencyLevel: newScore >= 80 ? UrgencyLevel.low : (newScore >= 50 ? UrgencyLevel.medium : UrgencyLevel.critical),
    );

    setState(() {
      _activeModel = updatedModel;
    });
    
    // Sync Global State
    ref.read(latestDiagnosticProvider.notifier).updateDiagnostic(updatedModel);

    try {
      await ref.read(maintenanceRepositoryProvider).submitMaintenanceAction(
        vehicleId: widget.vehicleId!,
        description: fault.issue,
        actionTaken: "Resolved by user via App",
        scoreImpact: impact,
      );
      
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Resolved! Health +$impact"),
              backgroundColor: const Color(0xFF00C853),
              behavior: SnackBarBehavior.floating,
          ),
        );
       }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting action: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  int _calculateImpact(UrgencyLevel severity) {
      switch(severity) {
          case UrgencyLevel.low: return 5;
          case UrgencyLevel.medium: return 10;
          case UrgencyLevel.high: return 20;
          case UrgencyLevel.critical: return 30;
      }
  }

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
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
            // Main Content
            if (_activeModel != null)
                 HealthReportWidget(
                     data: _activeModel!,
                     onResolve: _handleResolve,
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
            
            // Confetti Overlay
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
        ],
      ),
    );
  }
}
