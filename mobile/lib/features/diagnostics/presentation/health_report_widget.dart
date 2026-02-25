import 'package:autolink_mobile/features/diagnostics/domain/diagnostic_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HealthReportWidget extends StatelessWidget {
  final DiagnosticModel data;
  
  const HealthReportWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Absolute Black
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            
            // Speciality Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF1744).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF1744)),
                ),
                child: Text(
                  "ESPECIALIDAD REQUERIDA: ${data.requiredSpecialty.replaceAll('_', ' ')}",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFF1744),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 12
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            _SectionHeader(title: 'RESUMEN DEL DIAGNÓSTICO'),
            const SizedBox(height: 15),
            _ContentBox(
              child: Text(
                data.diagnosisSummary,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, height: 1.5),
              ),
            ),
            
            const SizedBox(height: 30),
            _SectionHeader(title: 'PRIMEROS AUXILIOS E INSTRUCCIONES TÉCNICAS'),
            const SizedBox(height: 15),
            _ContentBox(
              child: Text(
                data.technicalDetails,
                style: GoogleFonts.outfit(color: Colors.grey[300], fontSize: 14, height: 1.5),
              ),
              borderColor: const Color(0xFF00E5FF),
            ),
            
            const SizedBox(height: 30),
            _SectionHeader(title: 'REPUESTOS SUGERIDOS'),
            const SizedBox(height: 15),
            _ContentBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.suggestedParts.map((part) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.build_circle, color: Colors.amber, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(part, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15))),
                    ],
                  ),
                )).toList(),
              ),
            ),
            
            const SizedBox(height: 30),
            _SectionHeader(title: 'TIEMPO ESTIMADO DE REPARACIÓN'),
            const SizedBox(height: 15),
            _ContentBox(
              child: Row(
                children: [
                  const Icon(Icons.access_time_filled, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    "${data.estimatedLaborHours} Horas",
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.grey[600],
          fontSize: 12,
          letterSpacing: 2.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ContentBox extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  
  const _ContentBox({required this.child, this.borderColor = const Color(0xFF333333)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
