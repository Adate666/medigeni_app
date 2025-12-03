import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/dashboard/patient_dashboard.dart';
import '../screens/dashboard/doctor_dashboard.dart';
import '../screens/dashboard/admin_dashboard.dart';
import '../screens/tools/chatbot_screen.dart';
import '../screens/tools/bmi_calculator.dart';
import '../screens/tools/symptom_analyzer.dart';
import '../screens/tools/period_tracker.dart';

class AppRouter {
  static GoRouter getRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.isAuthenticated;
        final currentUser = authProvider.currentUser;
        final isAuthRoute = state.matchedLocation == '/auth';

        // Si non authentifié et pas sur la page d'auth, rediriger vers auth
        if (!isAuthenticated && !isAuthRoute) {
          return '/auth';
        }

        // Si authentifié et sur la page d'auth, rediriger vers le dashboard approprié
        if (isAuthenticated && isAuthRoute) {
          return _getDashboardRouteForRole(currentUser!.role);
        }

        // Protection des routes selon le rôle
        if (isAuthenticated && currentUser != null) {
          final route = state.matchedLocation;
          
          // Routes admin uniquement
          if (route.startsWith('/admin') && currentUser.role != UserRole.admin) {
            return _getDashboardRouteForRole(currentUser.role);
          }

          // Routes médecin uniquement
          if (route.startsWith('/doctor') && currentUser.role != UserRole.doctor) {
            return _getDashboardRouteForRole(currentUser.role);
          }

          // Routes patient uniquement
          if (route.startsWith('/patient') && currentUser.role != UserRole.patient) {
            return _getDashboardRouteForRole(currentUser.role);
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        // Routes patient
        GoRoute(
          path: '/patient/dashboard',
          builder: (context, state) => const PatientDashboard(),
        ),
        // Routes médecin
        GoRoute(
          path: '/doctor/dashboard',
          builder: (context, state) => const DoctorDashboard(),
        ),
        // Routes admin
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboard(),
        ),
        // Routes outils (accessibles à tous les utilisateurs authentifiés)
        GoRoute(
          path: '/tools/chatbot',
          builder: (context, state) => const ChatbotScreen(),
        ),
        GoRoute(
          path: '/tools/bmi',
          builder: (context, state) => const BMICalculator(),
        ),
        GoRoute(
          path: '/tools/symptoms',
          builder: (context, state) => const SymptomAnalyzer(),
        ),
        GoRoute(
          path: '/tools/period',
          builder: (context, state) => const PeriodTracker(),
        ),
      ],
    );
  }

  static String _getDashboardRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '/admin/dashboard';
      case UserRole.doctor:
        return '/doctor/dashboard';
      case UserRole.patient:
        return '/patient/dashboard';
    }
  }
}

