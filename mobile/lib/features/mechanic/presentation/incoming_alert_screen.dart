import 'package:autolink_mobile/features/client/presentation/live_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class IncomingAlertScreen extends StatefulWidget {
  final Map<String, dynamic> payload;

  const IncomingAlertScreen({super.key, required this.payload});

  @override
  State<IncomingAlertScreen> createState() => _IncomingAlertScreenState();
}

class _IncomingAlertScreenState extends State<IncomingAlertScreen> {
  // Mock customer location
  final LatLng _customerLocation = const LatLng(-33.4489, -70.6693);
  final Completer<GoogleMapController> _controller = Completer();
  bool _isAccepting = false;
  Timer? _gpsHandshakeTimer;

  @override
  void dispose() {
    _gpsHandshakeTimer?.cancel();
    super.dispose();
  }

  void _acceptService() async {
    setState(() { _isAccepting = true; });
    
    // Simulate Backend API Call: PATCH /services/{id}/accept
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Simulate GPS Handshake background loop
    _startGpsHandshake();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Servicio Aceptado. Transmitiendo GPS en vivo.', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
    );

    // Optionally navigate to navigation view
    Navigator.of(context).pop(); 
  }

  void _startGpsHandshake() {
    // This simulates hitting PATCH /mechanics/me/location every 30s
    _gpsHandshakeTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
       debugPrint("Simulating: PATCH /mechanics/me/location (lat/lon update sent to AutoLink Backend)");
    });
  }

  @override
  Widget build(BuildContext context) {
    final String specialty = widget.payload['specialty'] ?? 'Mecánica General';
    final String distanceKm = widget.payload['distance_km'] ?? '3.5';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: _customerLocation, zoom: 15),
                    mapType: MapType.dark,
                    markers: {
                      Marker(
                        markerId: const MarkerId('customer'),
                        position: _customerLocation,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        infoWindow: const InfoWindow(title: 'Vehículo Varado'),
                      ),
                    },
                    onMapCreated: (controller) => _controller.complete(controller),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "NUEVA URGENCIA CERCA",
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: const BoxDecoration(
                  color: Color(0xFF111111),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Detalles de la Falla (AI)", style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF333333)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.build, color: Color(0xFF00E5FF), size: 20),
                              const SizedBox(width: 8),
                              Text(specialty, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "El vehículo presenta humo blanco en el motor y pérdida de potencia masiva detectada por telemetría OBD2.",
                            style: GoogleFonts.outfit(color: Colors.grey[300], height: 1.5),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Distancia Estimada", style: GoogleFonts.outfit(color: Colors.grey[400])),
                        Text("$distanceKm km", style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isAccepting ? null : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                            ),
                            child: Text("IGNORAR", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isAccepting ? null : _acceptService,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5FF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                            ),
                            child: _isAccepting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                : Text("ACEPTAR SERVICIO", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
