import 'package:autolink_mobile/features/client/domain/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final int? healthScore;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.healthScore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          // Metallic/Glassmorphism effect
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C2F33), // Metallic Dark Grey
              Color(0xFF0D0D0D), // Deep Black
            ],
            stops: [0.0, 0.8],
          ),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
             // Subtle top-left highlight for metallic shine
             BoxShadow(
              color: Colors.white.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(-2, -2),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // Background Noise/Texture (Optional, represented by gradient for now)
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Brand & Health Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.brand.toUpperCase(),
                              style: GoogleFonts.outfit(
                                color: Colors.grey[400],
                                fontSize: 14,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              vehicle.model.toUpperCase(),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              vehicle.year.toString(),
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF00E5FF),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (healthScore != null)
                          _HealthBadge(score: healthScore!)
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Vehicle Image (Centered/Bottom)
                    Center(
                      child: Image.network(
                        _getMockImage(vehicle.model),
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.directions_car, size: 80, color: Colors.white24),
                      ),
                    ),
                    
                    const Spacer(),

                    // Actions / Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatusPill(icon: Icons.local_gas_station, label: "75%", color: Colors.white),
                        _StatusPill(icon: Icons.speed, label: "125k km", color: Colors.white),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMockImage(String model) {
    // Quick mock logic for demo purposes
    final m = model.toLowerCase();
    if (m.contains('supra')) return "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/2020_Toyota_GR_Supra_GT4_3.0_Front.jpg/640px-2020_Toyota_GR_Supra_GT4_3.0_Front.jpg";
    if (m.contains('mustang')) return "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/2018_Ford_Mustang_GT_5.0_Front.jpg/640px-2018_Ford_Mustang_GT_5.0_Front.jpg";
    if (m.contains('gtr') || m.contains('skyline')) return "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Nissan_GT-R_R35_Martini_Racing.jpg/640px-Nissan_GT-R_R35_Martini_Racing.jpg";
    return "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/2019_Toyota_Camry_L_Front.jpg/640px-2019_Toyota_Camry_L_Front.jpg"; // Fallback
  }
}

class _HealthBadge extends StatelessWidget {
  final int score;
  const _HealthBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    Color color = score > 70 ? const Color(0xFF00E5FF) : (score > 40 ? Colors.amber : const Color(0xFFFF1744));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           Icon(Icons.health_and_safety, color: color, size: 14),
           const SizedBox(width: 6),
           Text(
             "$score%",
             style: GoogleFonts.outfit(
               color: color,
               fontWeight: FontWeight.bold,
               fontSize: 12,
             ),
           ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  
  const _StatusPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[500], size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        )
      ],
    );
  }
}
