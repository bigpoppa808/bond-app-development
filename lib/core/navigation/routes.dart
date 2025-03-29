import 'package:flutter/material.dart';
import 'package:bond_app/features/auth/presentation/screens/login_screen.dart';
import 'package:bond_app/features/auth/presentation/screens/register_screen.dart';
import 'package:bond_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:bond_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:bond_app/features/profile/presentation/screens/location_privacy_screen.dart';
import 'package:bond_app/features/discovery/presentation/screens/discovery_screen.dart';

/// Class for managing app routes
class AppRoutes {
  /// Route name for the login screen
  static const String login = '/login';
  
  /// Route name for the register screen
  static const String register = '/register';
  
  /// Route name for the profile screen
  static const String profile = '/profile';
  
  /// Route name for the edit profile screen
  static const String editProfile = '/edit-profile';
  
  /// Route name for the location privacy screen
  static const String locationPrivacy = '/location-privacy';
  
  /// Route name for the discovery screen
  static const String discovery = '/discovery';
  
  /// Get app routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      profile: (context) => const ProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),
      locationPrivacy: (context) => const LocationPrivacyScreen(),
      discovery: (context) => const DiscoveryScreen(),
    };
  }
}
