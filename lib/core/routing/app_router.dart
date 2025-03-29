import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bond_app/app/app.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bond_app/features/auth/presentation/screens/login_screen.dart';
import 'package:bond_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:bond_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:bond_app/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:bond_app/features/home/presentation/screens/home_screen.dart';
import 'package:bond_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:bond_app/features/splash/presentation/screens/splash_screen.dart';

/// Router configuration for the Bond app
class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  /// Get the router configuration
  GoRouter get router => GoRouter(
        debugLogDiagnostics: true,
        initialLocation: '/',
        refreshListenable: GoRouterRefreshStream(authBloc.stream),
        redirect: (context, state) {
          final currentState = authBloc.state;
          final isLoggedIn = currentState is Authenticated;
          final isOnLoginPage = state.location == '/login';
          final isOnSignupPage = state.location == '/signup';
          final isOnSplashPage = state.location == '/';
          final isOnForgotPasswordPage = state.location == '/forgot-password';
          final isOnEmailVerificationPage = state.location == '/email-verification';

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
            path: '/profile',
            builder: (context, state) {
              final userId = state.queryParams['userId'] ?? 
                (authBloc.state is Authenticated ? (authBloc.state as Authenticated).user.id : '');
              
              // Load the profile data when navigating to this route
              context.read<ProfileBloc>().add(LoadProfile(userId));
              
              return const ProfileScreen();
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
