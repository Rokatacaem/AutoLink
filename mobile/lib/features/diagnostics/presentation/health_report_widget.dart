import 'dart:math';
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            _HealthGauge(score: data.healthScore),
            const SizedBox(height: 30),
            _UrgencyBadge(level: data.urgencyLevel),
            const SizedBox(height: 40),
            _SectionHeader(title: 'DETECTED FAULTS'),
            const SizedBox(height: 15),
            if (data.faults.isEmpty)
              const _EmptyState(message: "No faults detected. Vehicle is in good health.")
            else
              ...data.faults.map((fault) => _FaultCard(fault: fault)),
            
            const SizedBox(height: 30),
            if (data.recommendedActions.isNotEmpty) ...[
                _SectionHeader(title: 'RECOMMENDED ACTIONS'),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Column(
                    children: data.recommendedActions.map((action) => _ActionItem(action: action)).toList(),
                  ),
                ),
            ],
            const SizedBox(height: 50),
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

class _HealthGauge extends StatelessWidget {
  final int score;

  const _HealthGauge({required this.score});

  @override
  Widget build(BuildContext context) {
    Color scoreColor = _getScoreColor(score);

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: _GaugePainter(score: score, color: scoreColor),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w200, // Thin premium look
                ),
              ),
              Text(
                'HEALTH SCORE',
                style: GoogleFonts.outfit(
                  color: Colors.grey,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF00E5FF); // Tech Blue / Cyan
    if (score >= 50) return Colors.amber;
    return const Color(0xFFFF3D00); // Deep Orange/Red
  }
}

class _GaugePainter extends CustomPainter {
  final int score;
  final Color color;

  _GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;

    // Background Arc
    final bgPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth),
      pi * 0.75, // Start angle
      pi * 1.5,  // Sweep angle (270 degrees)
      false,
      bgPaint,
    );

    // Progress Arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2); // Glow effect

    final sweepAngle = (pi * 1.5) * (score / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth),
      pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _UrgencyBadge extends StatelessWidget {
  final UrgencyLevel level;

  const _UrgencyBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text = level.name.toUpperCase();

    switch (level) {
      case UrgencyLevel.low:
        color = const Color(0xFF00E5FF);
        break;
      case UrgencyLevel.medium:
        color = Colors.amber;
        break;
      case UrgencyLevel.high:
        color = Colors.orangeAccent;
        break;
      case UrgencyLevel.critical:
        color = const Color(0xFFFF1744);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)
        ]
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _FaultCard extends StatelessWidget {
  final Fault fault;

  const _FaultCard({required this.fault});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF222222),
            const Color(0xFF111111),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.grey,
          iconColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getSeverityColor(fault.severity),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: _getSeverityColor(fault.severity).withOpacity(0.4), blurRadius: 6)
              ]
            ),
          ),
          title: Text(
            fault.issue,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            fault.severity.name.toUpperCase(),
            style: GoogleFonts.outfit(
              color: _getSeverityColor(fault.severity),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                fault.description ?? "No details available.",
                style: GoogleFonts.outfit(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(UrgencyLevel severity) {
    switch (severity) {
      case UrgencyLevel.low: return const Color(0xFF00E5FF);
      case UrgencyLevel.medium: return Colors.amber;
      case UrgencyLevel.high: return Colors.orange;
      case UrgencyLevel.critical: return const Color(0xFFFF1744);
    }
  }
}

class _ActionItem extends StatelessWidget {
  final String action;

  const _ActionItem({required this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF00E5FF), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action,
              style: GoogleFonts.outfit(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
       decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      child: Center(
        child: Text(
           message,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.grey[500],
              fontSize: 14,
            ),
        ),
      ),
    );
  }
}
