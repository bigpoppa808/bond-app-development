import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String firebaseApiKey;
  final String projectId;
  
  // Analytics config
  final bool analyticsEnabled;
  
  // Feature flags
  final bool isNfcEnabled;
  final bool isTokenEconomyEnabled;
  
  static late AppConfig _instance;
  
  factory AppConfig.instance() {
    return _instance;
  }
  
  AppConfig._internal({
    required this.environment,
    required this.apiBaseUrl,
    required this.firebaseApiKey,
    required this.projectId,
    required this.analyticsEnabled,
    required this.isNfcEnabled,
    required this.isTokenEconomyEnabled,
  });
  
  static void initialize({required Environment environment}) {
    late final String apiBaseUrl;
    late final String firebaseApiKey;
    late final String projectId;
    late final bool analyticsEnabled;
    
    switch (environment) {
      case Environment.development:
        apiBaseUrl = 'https://identitytoolkit.googleapis.com';
        firebaseApiKey = 'YOUR_DEV_API_KEY'; // Replace with actual key in production
        projectId = 'bond-dbc1d';
        analyticsEnabled = false;
        break;
      case Environment.staging:
        apiBaseUrl = 'https://identitytoolkit.googleapis.com';
        firebaseApiKey = 'YOUR_STAGING_API_KEY'; // Replace with actual key in production
        projectId = 'bond-dbc1d';
        analyticsEnabled = true;
        break;
      case Environment.production:
        apiBaseUrl = 'https://identitytoolkit.googleapis.com';
        firebaseApiKey = 'YOUR_PROD_API_KEY'; // Replace with actual key in production
        projectId = 'bond-dbc1d';
        analyticsEnabled = true;
        break;
    }
    
    _instance = AppConfig._internal(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      firebaseApiKey: firebaseApiKey,
      projectId: projectId,
      analyticsEnabled: analyticsEnabled,
      isNfcEnabled: environment != Environment.development,
      isTokenEconomyEnabled: environment != Environment.development,
    );
  }
  
  bool get isProduction => environment == Environment.production;
  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  
  bool get shouldReportErrors => isProduction || isStaging;
}
