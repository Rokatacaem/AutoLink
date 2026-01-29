import 'package:flutter/material.dart';

class VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback onTap;

  const VehicleCard({super.key, required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[800]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      // Metallic Gradient Background Effect (Optional nuance)
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2A2A2A).withOpacity(0.3),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   // Header
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Icon(Icons.star_border, color: Colors.grey),
                       Text(
                         "${vehicle['brand']} ${vehicle['model']}".toUpperCase(),
                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
                       ),
                       const Icon(Icons.more_horiz, color: Colors.grey),
                     ],
                   ),
                   const SizedBox(height: 16),
                   
                   // Car Image Placeholder (Mocking the 3D car look)
                   Container(
                     height: 140,
                     width: double.infinity,
                     decoration: BoxDecoration(
                       // Placeholder for car image
                       image: const DecorationImage(
                         image: NetworkImage("https://purepng.com/public/uploads/large/purepng.com-white-toyota-yaris-carcarvehicletroy-1701527429117b3q2g.png"),
                         fit: BoxFit.contain,
                       ),
                     ),
                   ),

                   const SizedBox(height: 20),

                   // Car Info
                   Text(
                     "VIN: ${vehicle['vin']}",
                     style: TextStyle(color: Colors.grey[600], letterSpacing: 1),
                   ),
                   
                   const SizedBox(height: 24),

                   // Action Buttons Row (Health, Service, Value)
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                       _buildActionButton(context, Icons.favorite, "Health", Colors.redAccent),
                       _buildActionButton(context, Icons.build_circle, "Service", Colors.blueAccent, isActive: true),
                       _buildActionButton(context, Icons.monetization_on, "Value", Colors.greenAccent),
                     ],
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, {bool isActive = false}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? color : Colors.transparent, width: 2),
          ),
          child: Icon(icon, color: isActive ? color : Colors.grey, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
