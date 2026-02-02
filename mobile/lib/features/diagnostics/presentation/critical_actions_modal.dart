import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CriticalActionsModal extends StatelessWidget {
  const CriticalActionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF101010),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
           BoxShadow(color: Color(0xFFFF1744), blurRadius: 20, spreadRadius: 0, offset: Offset(0, -2))
        ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF1744), size: 48),
          const SizedBox(height: 16),
          Text(
            // AppLocalizations.of(context)!.criticalVehicleState
            'CRITICAL VEHICLE STATE',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // AppLocalizations.of(context)!.criticalVehicleStateMsg
            'Immediate attention required.',
            style: GoogleFonts.outfit(color: Colors.grey[400]),
          ),
          const SizedBox(height: 32),
          _ActionButton(
            label: "CALL ROADSIDE ASSISTANCE", // AppLocalizations.of(context)!.callRoadside
            icon: Icons.phone_in_talk,
            color: const Color(0xFFFF1744),
            onTap: () {
              Navigator.pop(context);
              // Implement Call Logic
            },
          ),
          const SizedBox(height: 16),
          _ActionButton(
            label: "SEND GPS TO MECHANIC", // AppLocalizations.of(context)!.sendGps
            icon: Icons.location_on,
            color: const Color(0xFF00E5FF),
            onTap: () {
              Navigator.pop(context);
               // Implement GPS Logic
            },
          ),
           const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
