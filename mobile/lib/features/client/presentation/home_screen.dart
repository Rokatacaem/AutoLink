import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Ensure this is available
import 'client_providers.dart';
import 'vehicle_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentVehicleIndex = 0;
  int _currentNavIndex = 0;

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

                // 2. Main Content (Carousel)
                Expanded(
                  child: vehiclesAsync.when(
                    data: (vehicles) {
                      if (vehicles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("No vehicles in garage", style: TextStyle(color: Colors.white54)),
                              TextButton(
                                onPressed: () => context.push('/add-vehicle'),
                                child: const Text("Add Vehicle"),
                              )
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: CarouselSlider.builder(
                                itemCount: vehicles.length,
                                itemBuilder: (context, index, realIndex) {
                                  return VehicleCard(
                                    vehicle: vehicles[index],
                                    onTap: () {
                                       // Navigate or expand details
                                    },
                                  );
                                },
                                options: CarouselOptions(
                                  height: MediaQuery.of(context).size.height * 0.55,
                                  enlargeCenterPage: true,
                                  viewportFraction: 0.8,
                                  enableInfiniteScroll: false,
                                  onPageChanged: (index, reason) {
                                    setState(() => _currentVehicleIndex = index);
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Dots Indicator
                           Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: vehicles.asMap().entries.map((entry) {
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(_currentVehicleIndex == entry.key ? 0.9 : 0.4),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
                    error: (_, __) => const Center(child: Text("Error loading vehicles", style: TextStyle(color: Colors.red))),
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
            child: _buildPanicButton(),
          ),
        ],
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

  Widget _buildPanicButton() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFF5252), Color(0xFFD50000)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () {
            // Panic Action
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Panic Button Pressed!")));
          },
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30),
               Text(
                "PANIC",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
              )
            ],
          ),
        ),
      ),
    );
  }

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
      onTap: () => setState(() => _currentNavIndex = index),
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
