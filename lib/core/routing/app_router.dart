import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bond_app/features/auth/presentation/screens/login_screen.dart';
import 'package:bond_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:bond_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:bond_app/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:bond_app/features/home/presentation/screens/home_screen.dart';
import 'package:bond_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:bond_app/features/profile/presentation/screens/privacy_settings_screen.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:bond_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:bond_app/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:bond_app/features/connections/presentation/screens/connections_screen.dart';
import 'package:bond_app/features/connections/presentation/screens/send_connection_request_screen.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:bond_app/features/profile/presentation/screens/location_privacy_screen.dart';

/// Router configuration for the Bond app
class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  /// Get the router configuration
  GoRouter get router => GoRouter(
        debugLogDiagnostics: true,
        initialLocation: '/',
        refreshListenable: GoRouterRefreshStream(authBloc.stream),
        redirect: (BuildContext context, GoRouterState state) {
          final currentState = authBloc.state;
          final isLoggedIn = currentState is Authenticated;
          final isOnLoginPage = state.matchedLocation == '/login';
          final isOnSignupPage = state.matchedLocation == '/signup';
          final isOnSplashPage = state.matchedLocation == '/';
          final isOnForgotPasswordPage = state.matchedLocation == '/forgot-password';
          final isOnEmailVerificationPage = state.matchedLocation == '/email-verification';

          // If the user is on the splash screen, let them stay there
          if (isOnSplashPage) {
            return null;
          }

          // Allow access to auth-related pages without being logged in
          if (!isLoggedIn && 
              (isOnLoginPage || 
               isOnSignupPage || 
               isOnForgotPasswordPage)) {
            return null;
          }

          // If the user is not logged in and not on an auth page, redirect to login
          if (!isLoggedIn && 
              !isOnLoginPage && 
              !isOnSignupPage && 
              !isOnForgotPasswordPage) {
            return '/login';
          }

          // If the user is logged in but on an auth page, redirect to home
          if (isLoggedIn && 
              (isOnLoginPage || 
               isOnSignupPage || 
               isOnForgotPasswordPage)) {
            return '/home';
          }

          // If the user is logged in and needs email verification
          if (isLoggedIn && 
              currentState is Authenticated && 
              !currentState.user.isEmailVerified && 
              !isOnEmailVerificationPage) {
            return '/email-verification';
          }

          // Allow the user to proceed to their intended destination
          return null;
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SplashScreen(),
          ),
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
          GoRoute(
            path: '/email-verification',
            builder: (context, state) => const EmailVerificationScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/discovery',
            builder: (context, state) => const DiscoveryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) {
              // Get userId from query parameters or from authenticated user
              String userId = '';
              if (state.queryParameters.containsKey('userId')) {
                userId = state.queryParameters['userId'] ?? '';
              } else if (authBloc.state is Authenticated) {
                userId = (authBloc.state as Authenticated).user.id;
              }
              
              // Load the profile data when navigating to this route
              if (userId.isNotEmpty) {
                context.read<ProfileBloc>().add(LoadProfile(userId));
              }
              
              return const ProfileScreen();
            },
          ),
          GoRoute(
            path: '/privacy-settings',
            builder: (context, state) {
              // Ensure profile is loaded
              if (authBloc.state is Authenticated) {
                final userId = (authBloc.state as Authenticated).user.id;
                final profileState = context.read<ProfileBloc>().state;
                
                // If profile isn't already loaded, load it
                if (profileState is! ProfileLoaded) {
                  context.read<ProfileBloc>().add(LoadProfile(userId));
                }
              }
              
              return const PrivacySettingsScreen();
            },
          ),
          GoRoute(
            path: '/location-privacy',
            builder: (context, state) {
              // Ensure profile is loaded
              if (authBloc.state is Authenticated) {
                final userId = (authBloc.state as Authenticated).user.id;
                final profileState = context.read<ProfileBloc>().state;
                
                // If profile isn't already loaded, load it
                if (profileState is! ProfileLoaded) {
                  context.read<ProfileBloc>().add(LoadProfile(userId));
                }
              }
              
              return const LocationPrivacyScreen();
            },
          ),
          GoRoute(
            path: '/connections',
            builder: (context, state) => const ConnectionsScreen(),
          ),
          GoRoute(
            path: '/send-connection-request',
            builder: (context, state) {
              // Get the receiver profile from the extra parameter
              final receiverProfile = state.extra as ProfileModel;
              return SendConnectionRequestScreen(receiverProfile: receiverProfile);
            },
          ),
        ],
      );
}

/// A [Listenable] implementation that uses a [Stream].
///
/// It allows [GoRouter] to listen to a [Stream] such as a [Bloc] state.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
