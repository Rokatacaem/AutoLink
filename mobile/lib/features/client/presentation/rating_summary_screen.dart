import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class RatingSummaryScreen extends ConsumerStatefulWidget {
  final int serviceRequestId;
  final String mechanicName;

  const RatingSummaryScreen({
    super.key,
    required this.serviceRequestId,
    required this.mechanicName,
  });

  @override
  ConsumerState<RatingSummaryScreen> createState() => _RatingSummaryScreenState();
}

class _RatingSummaryScreenState extends ConsumerState<RatingSummaryScreen> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isAIAccurate = true;
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);
    // Simulate API Call for MVP
    await Future.delayed(const Duration(seconds: 2));
    
    // In full implementation, this calls:
    // POST /services/{widget.serviceRequestId}/feedback
    // { "rating": _rating, "comment": _commentController.text, "is_ai_accurate": _isAIAccurate }

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("¡Gracias por tu evaluación!", style: GoogleFonts.outfit()),
          backgroundColor: Colors.green,
        )
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('CALIFICAR SERVICIO', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF00E5FF), size: 100),
            const SizedBox(height: 24),
            Text(
              "Servicio Finalizado",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "¿Cómo evaluarías el trabajo de ${widget.mechanicName}?",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 32),
            
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 48,
                  icon: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: index < _rating ? Colors.amber : Colors.grey[700],
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 24),

            // AI Accuracy Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.memory, color: Color(0xFF00E5FF), size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Diagnóstico IA", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("¿El diagnóstico inicial de la IA fue acertado?", style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 13)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isAIAccurate,
                    activeColor: const Color(0xFF00E5FF),
                    onChanged: (val) => setState(() => _isAIAccurate = val),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Comment Box
            TextField(
              controller: _commentController,
              maxLines: 4,
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Deja un comentario sobre tu experiencia (opcional)...",
                hintStyle: GoogleFonts.outfit(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Submit Button
            _isSubmitting
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
                : ElevatedButton(
                    onPressed: _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                    ),
                    child: Text(
                      "ENVIAR EVALUACIÓN",
                      style: GoogleFonts.outfit(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
