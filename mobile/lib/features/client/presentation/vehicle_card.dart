import 'package:flutter/material.dart';

class VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback onTap;

  const VehicleCard({super.key, required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        // Simulating the metallic border/glow
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[800]!,
            Colors.black,
            Colors.grey[900]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Container(
        // Inner metallic border effect
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2C2F33),
                const Color(0xFF141414), 
              ]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Car Image
              Expanded(
                flex: 3,
                child: Image.network(
                  "https://purepng.com/public/uploads/large/purepng.com-white-toyota-yaris-carcarvehicletroy-1701527429117b3q2g.png",
                  fit: BoxFit.contain,
                ),
              ),
              
              const SizedBox(height: 10),

              // Title and Subtitle
              Column(
                children: [
                   Text(
                    "${vehicle['brand'] ?? 'TOYOTA'} ${vehicle['model'] ?? 'YARIS'}".toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Logo Tacas", // Placeholder or from data
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Actions Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(Icons.favorite, "Salud", Colors.redAccent),
                    // Use a divider if needed, but spaceAround handles it well
                    _buildActionButton(Icons.build, "Servicio", const Color(0xFFB0BEC5)), // Silver/Blue-ish
                    _buildActionButton(Icons.attach_money, "Valor", Colors.greenAccent),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
