import 'package:flutter/foundation.dart';
import 'package:fresh_bond_app/core/config/app_config.dart';

/// Environment configuration helper class
class EnvConfig {
  /// Initialize the application environment based on build mode
  static void setupEnvironment() {
    // Use development for debug mode, production for release
    final environment = kReleaseMode 
      ? Environment.production 
      : kProfileMode 
        ? Environment.staging 
        : Environment.development;
    
    AppConfig.initialize(environment: environment);
    
    debugPrint('App initialized with ${environment.name} environment');
  }
  
  /// Get current environment name for logging
  static String get currentEnvName => AppConfig.instance().environment.name;
  
  /// Check if we're running in debug mode
  static bool get isDebugMode => kDebugMode;
  
  /// Check if analytics should be enabled
  static bool get shouldEnableAnalytics => AppConfig.instance().analyticsEnabled;
}
