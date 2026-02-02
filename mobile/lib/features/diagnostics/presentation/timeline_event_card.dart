import 'package:autolink_mobile/features/diagnostics/domain/health_history_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class TimelineEventCard extends StatelessWidget {
  final HealthHistoryRecord record;
  final bool isLast;

  const TimelineEventCard({super.key, required this.record, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final color = _getColor(record.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.6), blurRadius: 8, spreadRadius: 1)
                    ]
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          
          // Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          record.type.name.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          "${record.healthScore}%",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      record.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.description,
                      style: GoogleFonts.outfit(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(record.timestamp),
                          style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 11),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Color _getColor(HealthEventType type) {
    switch (type) {
      case HealthEventType.maintenance: return Colors.greenAccent;
      case HealthEventType.alert: return const Color(0xFFFF1744);
      case HealthEventType.scan: return const Color(0xFF00E5FF);
    }
  }

  String _formatDate(DateTime dt) {
    // Simple formatter (requires intl for better formatting, but keeping it simple for now)
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}
