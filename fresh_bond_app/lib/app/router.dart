import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/app/presentation/screens/main_shell.dart';
import 'package:fresh_bond_app/core/di/service_locator.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fresh_bond_app/features/auth/presentation/screens/login_screen.dart';
import 'package:fresh_bond_app/features/discover/presentation/screens/discover_screen.dart';
import 'package:fresh_bond_app/features/home/presentation/screens/home_screen.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_event.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_state.dart';
import 'package:fresh_bond_app/features/meetings/presentation/screens/meeting_details_screen.dart';
import 'package:fresh_bond_app/features/meetings/presentation/screens/meeting_form_screen.dart';
import 'package:fresh_bond_app/features/meetings/presentation/screens/meetings_screen.dart';
import 'package:fresh_bond_app/features/messages/presentation/screens/messages_screen.dart';
import 'package:fresh_bond_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:fresh_bond_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:go_router/go_router.dart';

/// Router configuration for the app
class AppRouter {
  static final AuthRepository _authRepository = ServiceLocator.getIt<AuthRepository>();
  
  /// Create the router
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      redirect: _handleRedirect,
      routes: [
        // Auth routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        
        // Main app shell with nested routes
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            // Home route
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            
            // Discover route
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoverScreen(),
            ),
            
            // Messages route
            GoRoute(
              path: '/messages',
              builder: (context, state) => const MessagesScreen(),
            ),
            
            // Notifications route
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
            
            // Profile route
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            
            // Meetings route
            GoRoute(
              path: '/meetings',
              builder: (context, state) => const MeetingsScreen(),
            ),
            
            // Meeting details route
            GoRoute(
              path: '/meetings/details',
              builder: (context, state) {
                final meetingId = state.uri.queryParameters['id'] ?? '';
                if (meetingId.isEmpty) {
                  return const Scaffold(body: Center(child: Text('Meeting ID is required')));
                }
                return MeetingDetailsScreen(meetingId: meetingId);
              },
            ),
            
            // Create meeting route
            GoRoute(
              path: '/meetings/create',
              builder: (context, state) {
                final connectionId = state.uri.queryParameters['connectionId'];
                return MeetingFormScreen(connectionId: connectionId);
              },
            ),
            
            // Edit meeting route
            GoRoute(
              path: '/meetings/edit',
              builder: (context, state) {
                final meetingId = state.uri.queryParameters['id'] ?? '';
                if (meetingId.isEmpty) {
                  return const Scaffold(body: Center(child: Text('Meeting ID is required')));
                }
                // We need to fetch the meeting before navigating to the edit screen
                // This would typically be handled in the UI layer
                return BlocBuilder<MeetingBloc, MeetingState>(
                  builder: (context, state) {
                    if (state is MeetingLoadedState) {
                      return MeetingFormScreen(meetingToEdit: state.meeting);
                    }
                    
                    // If meeting is not loaded, return a loading screen
                    // and dispatch the load event
                    if (state is! MeetingLoadingState) {
                      context.read<MeetingBloc>().add(LoadMeetingEvent(meetingId));
                    }
                    
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  },
                );
              },
            ),
          ],
        ),
        
        // Redirect root to home or login
        GoRoute(
          path: '/',
          redirect: (context, state) async {
            final isSignedIn = await _authRepository.isSignedIn();
            return isSignedIn ? '/home' : '/login';
          },
        ),
      ],
    );
  }
  
  /// Handle redirects based on authentication state
  static Future<String?> _handleRedirect(BuildContext context, GoRouterState state) async {
    // Get the current auth state
    final isSignedIn = await _authRepository.isSignedIn();
    
    // Get the current path
    final path = state.matchedLocation;
    
    // If the user is not signed in and trying to access protected routes
    if (!isSignedIn && 
        !path.startsWith('/login') && 
        !path.startsWith('/signup') && 
        !path.startsWith('/forgot-password')) {
      return '/login';
    }
    
    // If the user is signed in and trying to access auth routes
    if (isSignedIn && 
        (path.startsWith('/login') || 
         path.startsWith('/signup') || 
         path.startsWith('/forgot-password'))) {
      return '/home';
    }
    
    // No redirect needed
    return null;
  }
}
