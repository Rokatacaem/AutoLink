import 'package:autolink_mobile/features/diagnostics/data/diagnostic_state.dart';
import 'package:autolink_mobile/features/diagnostics/presentation/critical_actions_modal.dart';
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
    // Watch global diagnostic state
    final latestDiagnostic = ref.watch(latestDiagnosticProvider);
    final bool isCritical = latestDiagnostic != null && latestDiagnostic.healthScore < 30;

    // Trigger haptics if critical and widget builds (caution with loop, maybe do in useEffect or callback)
    // For simplicity in this widget, we do it on interaction or just let the animation be the visual cue.
    // Real-time vibration loop might be annoying without user interaction, 
    // so we'll vibrate ONCE when state becomes critical or rely on visual pulse.
    
    // We can define the colors based on state
    final List<Color> gradientColors = isCritical 
        ? [const Color(0xFF00E5FF), const Color(0xFFFF1744)] // Emergency Cyan/Red Mixed
        : [const Color(0xFFFF5252), const Color(0xFFD50000)]; // Standard Red

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
             if (isCritical) {
               // Haptic feedback on press
               if (await Vibration.hasVibrator() ?? false) {
                 Vibration.vibrate();
               }
               
               if (context.mounted) {
                 showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const CriticalActionsModal(),
                 );
               }
             } else {
               // Standard Action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Panic Button Pressed! (No Critical Issues Detected)")),
                );
             }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCritical ? Icons.warning_rounded : Icons.warning_amber_rounded,
                color: Colors.white,
                size: 30,
              ),
              if (isCritical)
                Text(
                  // AppLocalizations.of(context)!.critical
                  "CRITICAL", // Placeholder until gen runs
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                )
              else
                 Text(
                  // AppLocalizations.of(context)!.panicButton
                  "PANIC", // Placeholder until gen runs
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
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
