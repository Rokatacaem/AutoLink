import 'package:autolink_mobile/features/client/presentation/live_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final double serviceCost;
  final double diagnosticsCost;
  final double urgencyFee;

  const PaymentCheckoutScreen({
    super.key,
    required this.serviceCost,
    this.diagnosticsCost = 15000,
    this.urgencyFee = 5000,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  bool _isProcessing = false;
  double get total => widget.serviceCost + widget.diagnosticsCost + widget.urgencyFee;

  void _simulatePayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate Mercado Pago webhook processing delay
    await Future.delayed(const Duration(seconds: 4));
    
    if (mounted) {
      setState(() => _isProcessing = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 64),
            const SizedBox(height: 16),
            Text(
              "Pago Retenido",
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "El pago de \$${total.toStringAsFixed(0)} ha sido retenido de forma segura.\n\nEl mecánico ha sido notificado y se dirige a tu ubicación.",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.grey[300]),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushReplacement(
                   MaterialPageRoute(builder: (context) => const LiveTrackingScreen())
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "VER ESTADO DE LA GRÚA",
                style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return _buildProcessingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('CHECKOUT SEGURO', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 30),
            Text(
              "MÉTODO DE PAGO",
              style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12, letterSpacing: 2.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildMercadoPagoPlaceholder(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _simulatePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 10,
                shadowColor: const Color(0xFF00E5FF).withOpacity(0.5),
              ),
              child: Text(
                "AUTORIZAR RETENCIÓN",
                style: GoogleFonts.outfit(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No se liberarán los fondos al taller sino hasta que confirmes la solución del problema en la app.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 12),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "RESUMEN DE ASISTENCIA",
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _SummaryRow(label: "Diagnóstico IA", amount: widget.diagnosticsCost),
          _SummaryRow(label: "Tarifa Urgencia", amount: widget.urgencyFee),
          _SummaryRow(label: "Cotización Mecánico", amount: widget.serviceCost),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Color(0xFF333333)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("\$${total.toStringAsFixed(0)}", style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMercadoPagoPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF009EE3).withOpacity(0.1), // MP Blue
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF009EE3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF009EE3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.handshake, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mercado Pago",
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Tarjetas, Efectivo o Saldo en cuenta",
                  style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF00E5FF)),
        ],
      ),
    );
  }

  Widget _buildProcessingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF00E5FF)),
            const SizedBox(height: 30),
            Text(
              "CONECTANDO CON MERCADO PAGO...",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, letterSpacing: 2.0),
            ),
            const SizedBox(height: 10),
            Text(
              "Esperando confirmación del Webhook",
              style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;

  const _SummaryRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 14)),
          Text("\$${amount.toStringAsFixed(0)}", style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
