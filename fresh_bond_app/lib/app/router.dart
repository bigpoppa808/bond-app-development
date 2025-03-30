import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/app/presentation/screens/main_shell.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_bloc.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_state.dart';
import 'package:fresh_bond_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:fresh_bond_app/features/auth/presentation/screens/login_screen.dart';
import 'package:fresh_bond_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:fresh_bond_app/features/notifications/presentation/screens/notifications_screen_v2.dart';
import 'package:fresh_bond_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

/// Manages the application's routing using GoRouter
class AppRouter {
  final AuthBloc _authBloc;

  AppRouter(this._authBloc);

  /// Get the router instance
  GoRouter get router => _router;

  /// Router redirects
  String? _authGuard(BuildContext context, GoRouterState state) {
    final authState = _authBloc.state;
    final isLoggedIn = authState is AuthAuthenticatedState;
    
    // List of auth routes that don't need redirection
    final isAuthRoute = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/signup' || 
                        state.matchedLocation == '/forgot-password';
    
    // If not authenticated and not already on auth route, redirect to login
    if (!isLoggedIn && !isAuthRoute && state.matchedLocation != '/splash') {
      return '/login';
    }
    
    // If authenticated and on auth route, redirect to home
    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }
    
    // No redirection needed
    return null;
  }

  /// Define the router configuration
  late final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: _authGuard,
    routes: [
      // Splash and onboarding
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main app routes - using the shell
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainShell(initialIndex: 0),
      ),
      GoRoute(
        path: '/discover',
        builder: (context, state) => const MainShell(initialIndex: 1),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainShell(initialIndex: 2),
      ),
      
      // Other screens
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreenV2(),
      ),
    ],
  );
}
