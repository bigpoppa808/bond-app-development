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

          // If the user is logged in but email is not verified, and not on verification page
          if (isLoggedIn && 
              currentState is Authenticated && 
              !currentState.user.isEmailVerified && 
              !isOnEmailVerificationPage) {
            return '/email-verification';
          }

          // If the user is logged in and on an auth page, redirect to home
          if (isLoggedIn && 
              (isOnLoginPage || 
               isOnSignupPage || 
               isOnForgotPasswordPage)) {
            return '/home';
          }

          // No redirection needed
          return null;
        },
        routes: [
          // Splash screen route
          GoRoute(
            path: '/',
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
          GoRoute(
            path: '/email-verification',
            builder: (context, state) => const EmailVerificationScreen(),
          ),
          
          // Home route
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
        ],
        errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Text(
              'Error: ${state.error}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
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
