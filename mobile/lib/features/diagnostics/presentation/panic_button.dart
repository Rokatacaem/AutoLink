import 'package:autolink_mobile/features/diagnostics/presentation/urgency_flow_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

class PanicButton extends ConsumerStatefulWidget {
  const PanicButton({super.key});

  @override
  ConsumerState<PanicButton> createState() => _PanicButtonState();
}

class _PanicButtonState extends ConsumerState<PanicButton> {
  @override
  Widget build(BuildContext context) {
    // The panic button is always available as an emergency trigger
    const bool isCritical = true;

    final List<Color> gradientColors = [const Color(0xFFFF1744), const Color(0xFFD50000)]; // Deep Red

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: gradientColors),
        boxShadow: [
          BoxShadow(
            color: (isCritical ? const Color(0xFFFF1744) : Colors.redAccent).withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(isCritical ? 0.8 : 0.2), 
          width: isCritical ? 3 : 2
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () async {
               // Haptic feedback on press
               if (await Vibration.hasVibrator() ?? false) {
                 Vibration.vibrate();
               }
               
               if (context.mounted) {
                 Navigator.of(context).push(MaterialPageRoute(
                   builder: (context) => const UrgencyFlowScreen(),
                 ));
               }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 30,
              ),
              const Text(
                  "EMERGENCY", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
              )
            ],
          ),
        ),
      ),
    );

    // Apply pulse animation if critical
    if (isCritical) {
      return button.animate(onPlay: (controller) => controller.repeat())
          .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 600.ms, curve: Curves.easeInOut)
          .then()
          .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeInOut)
          .shimmer(duration: 1200.ms, color: const Color(0xFF00E5FF).withOpacity(0.4));
    }

    return button;
  }
}
