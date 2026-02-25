import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  
  // Mock coordinates for Santiago, Chile area
  final LatLng _userLocation = const LatLng(-33.4489, -70.6693);
  LatLng _mechanicLocation = const LatLng(-33.4691, -70.6420);

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Timer? _locationTimer;

  int _etaMinutes = 15;
  double _distanceKm = 4.2;

  @override
  void initState() {
    super.initState();
    _setupMapData();
    _startSimulatedTracking();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _setupMapData() {
    _markers = {
      Marker(
        markerId: const MarkerId('user'),
        position: _userLocation,
        infoWindow: const InfoWindow(title: 'Tu Ubicación'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      Marker(
        markerId: const MarkerId('mechanic'),
        position: _mechanicLocation,
        infoWindow: const InfoWindow(title: 'Tallerista en camino'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      )
    };

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        color: const Color(0xFF00E5FF),
        width: 5,
        points: [_userLocation, _mechanicLocation],
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      )
    };
  }

  void _startSimulatedTracking() {
    // Simulate mechanic moving towards user every 3 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_distanceKm <= 0.1) {
        timer.cancel();
        return;
      }

      setState(() {
         // Move mechanic 10% closer to user for simulation
         double newLat = _mechanicLocation.latitude + (_userLocation.latitude - _mechanicLocation.latitude) * 0.1;
         double newLng = _mechanicLocation.longitude + (_userLocation.longitude - _mechanicLocation.longitude) * 0.1;
         _mechanicLocation = LatLng(newLat, newLng);
         
         // Update distance and ETA
         _distanceKm = _distanceKm * 0.9;
         _etaMinutes = max(1, (_etaMinutes * 0.9).round());

         _setupMapData(); // Refresh markers and polyline
      });

      _updateCamera();
    });
  }

  Future<void> _updateCamera() async {
    final GoogleMapController controller = await _controller.future;
    
    // Bounds to fit both markers
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(_userLocation.latitude, _mechanicLocation.latitude),
        min(_userLocation.longitude, _mechanicLocation.longitude),
      ),
      northeast: LatLng(
        max(_userLocation.latitude, _mechanicLocation.latitude),
        max(_userLocation.longitude, _mechanicLocation.longitude),
      ),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('SEGUIMIENTO EN VIVO', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _userLocation,
              zoom: 13.0,
            ),
            mapType: MapType.dark,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              // Wait a bit for map to render before setting bounds
              Future.delayed(const Duration(milliseconds: 500), _updateCamera);
            },
          ),
          
          // Bottom Info Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, -5))]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Row(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: const Color(0xFF00E5FF).withOpacity(0.1),
                           shape: BoxShape.circle,
                           border: Border.all(color: const Color(0xFF00E5FF))
                         ),
                         child: const Icon(Icons.local_shipping, color: Color(0xFF00E5FF), size: 30),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text("Tallerista Mecánico en Camino", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                             Text("Camioneta Ford Ranger", style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 14)),
                           ],
                         ),
                       ),
                     ],
                   ),
                   const Padding(
                     padding: EdgeInsets.symmetric(vertical: 20),
                     child: Divider(color: Color(0xFF333333)),
                   ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       _buildMetric("ETA", "$_etaMinutes min", Icons.timer),
                       _buildMetric("Distancia", "${_distanceKm.toStringAsFixed(1)} km", Icons.route),
                     ],
                   ),
                   const SizedBox(height: 20),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton.icon(
                        onPressed: () {
                           // Action to contact mechanic
                        },
                        icon: const Icon(Icons.phone, color: Colors.black),
                        label: Text("CONTACTAR TALLERISTA", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                        ),
                     ),
                   )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[500], size: 24),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 12, letterSpacing: 1.0)),
      ],
    );
  }
}
