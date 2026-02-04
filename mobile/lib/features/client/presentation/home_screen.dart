import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'client_providers.dart';
import 'vehicle_card.dart';
import 'empty_garage_card.dart';
import 'selected_vehicle_provider.dart';
import '../../diagnostics/presentation/panic_button.dart';
import '../../diagnostics/data/diagnostic_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(myVehiclesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF101010), // Deep dark background
      body: Stack(
        children: [
          // Background subtle pattern or gradient could go here
          
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                _buildHeader(),

                const SizedBox(height: 10),

                // 2. Main Content (Premium Garage Carousel)
                Expanded(
                  child: vehiclesAsync.when(
                    data: (vehicles) {
                      if (vehicles.isEmpty) {
                        return Center(
                          child: EmptyGarageCard(
                            onTap: () => context.push('/add-vehicle'),
                          ),
                        );
                      }
                      
                      // Ensure logic provider is listening
                      ref.watch(vehicleSelectionLogicProvider);
                      
                      return Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: vehicles.length,
                              onPageChanged: (index) {
                                ref.read(selectedVehicleIndexProvider.notifier).state = index;
                              },
                              itemBuilder: (context, index) {
                                final vehicle = vehicles[index];
                                // We check if this specific card index matches the currently selected one in State
                                // Note: This might cause rebuild of all cards on swipe. Optimized approach handles this locally.
                                final isSelected = ref.watch(selectedVehicleIndexProvider) == index;
                                final latestDiagnostic = ref.watch(latestDiagnosticProvider);
                                
                                return AnimatedScale(
                                  duration: const Duration(milliseconds: 300),
                                  scale: isSelected ? 1.0 : 0.9,
                                  child: VehicleCard(
                                    vehicle: vehicle,
                                    // Only show health score on the active card if we have it
                                    // In a real app we'd map diagnostic by vehicle ID.
                                    // Here we assume global latestDiagnostic belongs to selected vehicle.
                                    healthScore: (isSelected && latestDiagnostic != null) ? latestDiagnostic.healthScore : null,
                                    onTap: () {
                                       // Navigate
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Dots Indicator linked to Controller
                          SmoothPageIndicator(
                              controller: _pageController,
                              count: vehicles.length,
                              effect: const ExpandingDotsEffect(
                                activeDotColor: Color(0xFF00E5FF),
                                dotColor: Colors.grey,
                                dotHeight: 8,
                                dotWidth: 8,
                                expansionFactor: 4,
                                spacing: 8,
                              ),
                           ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
                    error: (_, __) => const Center(child: Text("Error loading garage", style: TextStyle(color: Colors.red))),
                  ),
                ),
                
                 // Space for bottom nav
                 const SizedBox(height: 80),
              ],
            ),
          ),

          // 3. Custom Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavBar(),
          ),

          // 4. Floating Panic Button
          Positioned(
            bottom: 60, // Adjust to float above nav bar
            right: 30, // Positioned to the right as per suggestion or center if desired
            child: const PanicButton(),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Above Navigation Bar
        child: FloatingActionButton(
          onPressed: () => context.push('/add-vehicle'),
          backgroundColor: const Color(0xFFFF6B00), // Brand Orange
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "HOLA, ",
                      style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                    TextSpan(
                      text: "RODRIGO", // TODO: Get from user provider
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Home - Garaje",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              const CircleAvatar(
                 radius: 20,
                 backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=a042581f4e29026704d"), // Placeholder
              ),
              const SizedBox(width: 16),
              Stack(
                children: [
                  const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  // Placeholder removed, replaced by dedicated widget import
  // Ensure 'package:autolink_mobile/features/diagnostics/presentation/panic_button.dart' is imported at the top

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.calendar_today, 1),
          // Space for visual balance if panic button is center, but it's on right in image
          // If panic is right, we can just distribute evenly
           _buildNavItem(Icons.camera_alt, 2),
           _buildNavItem(Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentNavIndex = index);
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            // Calendar -> Mechanic List/Appointments
            context.push('/mechanic-list');
            break;
          case 2:
            // Camera -> AI Diagnosis
            context.push('/diagnosis');
            break;
          case 3:
            // Profile -> Placeholder
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile Feature Coming Soon!")),
            );
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: isSelected ? BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16)
        ) : null,
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
}
