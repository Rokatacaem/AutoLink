import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/client/presentation/home_screen.dart';
import '../../features/client/presentation/add_vehicle_screen.dart';
import '../../features/client/presentation/mechanic_list_screen.dart';
import '../../features/client/presentation/book_appointment_screen.dart';
import '../../features/client/presentation/ai_chat_screen.dart';
import '../../features/mechanic/presentation/mechanic_home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  // FIXME: TEMPORARY FORCE REDIRECT FOR TESTING - ALLOW NAVIGATION
  redirect: (context, state) {
     final path = state.uri.path;
     
     // Allow specific routes for testing
     if (path == '/home' || 
         path == '/add-vehicle' || 
         path == '/mechanic-list' || 
         path == '/book-appointment' || // Assuming this is the path
         path.startsWith('/diagnosis')) {
       return null; 
     }

     // Redirect everything else to home (especially login/register/slash)
     return '/home';
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home', // Client Home
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/diagnosis',
      builder: (context, state) {
        final vehicleId = state.uri.queryParameters['vehicleId'];
        final vehicleName = state.uri.queryParameters['name'];
        return AIChatScreen(vehicleId: vehicleId, vehicleName: vehicleName);
      },
    ),
    GoRoute(
      path: '/mechanic-home', // Mechanic Home
      builder: (context, state) => const MechanicHomeScreen(),
    ),
    GoRoute(
      path: '/add-vehicle',
      builder: (context, state) => const AddVehicleScreen(),
    ),
    GoRoute(
      path: '/mechanic-list',
      builder: (context, state) => const MechanicListScreen(),
    ),
    GoRoute(
      path: '/book-appointment',
      builder: (context, state) {
        final params = state.uri.queryParameters;
        return BookAppointmentScreen(
          mechanicId: params['mechanicId']!,
          mechanicName: params['name']!,
        );
      },
    ),
  ],
);
