import 'package:autolink_mobile/features/diagnostics/data/diagnostic_repository.dart';
import 'package:autolink_mobile/features/diagnostics/domain/diagnostic_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:autolink_mobile/features/diagnostics/presentation/health_report_widget.dart';
import 'package:autolink_mobile/features/client/presentation/payment_checkout_screen.dart';
import 'package:dio/dio.dart';
import 'package:autolink_mobile/core/api_client.dart';

class UrgencyFlowScreen extends ConsumerStatefulWidget {
  const UrgencyFlowScreen({super.key});

  @override
  ConsumerState<UrgencyFlowScreen> createState() => _UrgencyFlowScreenState();
}

class _UrgencyFlowScreenState extends ConsumerState<UrgencyFlowScreen> {
  int _currentStep = 0; // 0: Diagnosing, 1: Viewing AI Advisor, 2: Radar / Finding Mechanics
  DiagnosticModel? _diagnosticData;
  List<dynamic> _nearestMechanics = [];
  bool _fcmSent = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startUrgencyFlow();
  }

  Future<void> _startUrgencyFlow() async {
    try {
      // Step 1: Trigger AI Diagnosis with auto_draft_request = true
      // We send a generic emergency description, or ideally grab it from a local form/voice note.
      // For MVP, hardcoding a critical fault simulation if needed, or prompt the user. 
      // Assuming a generic emergency here for the panic button:
      final diag = await ref.read(diagnosticRepositoryProvider).getDiagnosticReport(
        description: "EMERGENCY: The engine suddenly stopped while driving and smoke is coming from the hood. Check engine light is flashing red.",
        vehicleId: 1, // Hardcoded for MVP or use selected vehicle
        autoDraftRequest: true,
      );

      if (!mounted) return;
      setState(() {
        _diagnosticData = diag;
        _currentStep = 1; // Show AI Advisor
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to analyze emergency: $e';
      });
    }
  }

  Future<void> _startRadar() async {
    setState(() {
      _currentStep = 2; // Show Radar
    });

    try {
      // Mock coordinates for user location (e.g. Santiago context)
      double lat = -33.4489;
      double lon = -70.6693;
      String specialty = _diagnosticData!.requiredSpecialty;

      final dio = ref.read(apiClientProvider).dio;
      final response = await dio.get(
        '/mechanics/nearest_by_specialty',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'specialty': specialty,
        }
      );

      if (!mounted) return;
      setState(() {
        _nearestMechanics = response.data;
        _fcmSent = true;
      });

      // Show FCM Confirmation SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Alerta enviada a los mecánicos ${specialty.replaceAll('_', ' ')} más cercanos. Tiempo estimado de respuesta: 5 min"),
          backgroundColor: const Color(0xFF00E5FF),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        )
      );

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to find mechanics: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'EMERGENCY MODE', 
          style: GoogleFonts.outfit(color: const Color(0xFFFF1744), fontWeight: FontWeight.bold, letterSpacing: 2)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
      );
    }

    switch (_currentStep) {
      case 0:
        return _buildAnalyzingView();
      case 1:
        return _buildAIAdvisorView();
      case 2:
        return _buildRadarView();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAnalyzingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFFF1744)),
          const SizedBox(height: 24),
          Text(
            "Analizando la situación de emergencia y\nautogenerando solicitud de servicio...",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
          )
        ],
      ),
    );
  }

  Widget _buildAIAdvisorView() {
    return Column(
      children: [
        Expanded(child: HealthReportWidget(data: _diagnosticData!)),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
             color: Color(0xFF111111),
             border: Border(top: BorderSide(color: Color(0xFF333333)))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               ElevatedButton.icon(
                  onPressed: _startRadar,
                  icon: const Icon(Icons.radar, color: Colors.white),
                  label: Text("BUSCAR TALLERES CERCANOS", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF1744),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
               )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRadarView() {
    return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
            // Radar Animation Placeholder
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5), width: 2),
                color: const Color(0xFF00E5FF).withOpacity(0.1),
              ),
              child: const Center(
                child: Icon(Icons.my_location, size: 64, color: Color(0xFF00E5FF)),
              ),
            ),
            const SizedBox(height: 40),
            if (!_fcmSent) ...[
                const CircularProgressIndicator(color: Color(0xFF00E5FF)),
                const SizedBox(height: 20),
                Text(
                  "Buscando talleres ${_diagnosticData!.requiredSpecialty}...",
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
                )
            ] else ...[
               const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 64),
               const SizedBox(height: 20),
               Text(
                  "¡Notificaciones Enviadas!",
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
               ),
               const SizedBox(height: 10),
               Text(
                  "Encontramos ${_nearestMechanics.length} talleres cercanos.",
                  style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 16),
               ),
               const SizedBox(height: 40),
               ElevatedButton.icon(
                  onPressed: () {
                     // Simulate mechanic sending a quote of $45,000 for the fix
                     Navigator.of(context).pushReplacement(MaterialPageRoute(
                       builder: (context) => const PaymentCheckoutScreen(serviceCost: 45000),
                     ));
                  },
                  icon: const Icon(Icons.payment, color: Colors.black),
                  label: Text("VER COTIZACIÓN Y PAGAR", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
               )
            ]
         ],
       ),
    );
  }
}
