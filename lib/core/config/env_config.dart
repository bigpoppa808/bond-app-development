import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// A class to manage environment variables and credentials securely
class EnvConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: 'credentials/.env');
  }

  // Firebase credentials
  static String get firebaseProjectId => 
      dotenv.env['FIREBASE_PROJECT_ID'] ?? 'bond-dbc1d';
  
  static String get firebaseServiceAccountPath => 
      dotenv.env['FIREBASE_SERVICE_ACCOUNT_PATH'] ?? './credentials/firebase-service-account.json';
  
  // Algolia credentials
  static String get algoliaAppId => 
      dotenv.env['ALGOLIA_APP_ID'] ?? '7ZNGJXM461';
  
  static String get algoliaApiKey => 
      dotenv.env['ALGOLIA_API_KEY'] ?? '';
  
  static String get algoliaIndexName => 
      dotenv.env['ALGOLIA_INDEX_NAME'] ?? 'bond_users';
  
  // Google Maps
  static String get googleMapsApiKey => 
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  
  // Stripe
  static String get stripePublishableKey => 
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  
  static String get stripeSecretKey => 
      dotenv.env['STRIPE_SECRET_KEY'] ?? '';
  
  static String get stripeWebhookSecret => 
      dotenv.env['STRIPE_WEBHOOK_SECRET'] ?? '';
  
  /// Validates that all required credentials are available
  static bool validateCredentials() {
    final List<String> missingCredentials = [];
    
    if (firebaseProjectId.isEmpty) missingCredentials.add('Firebase Project ID');
    if (algoliaAppId.isEmpty) missingCredentials.add('Algolia App ID');
    if (algoliaApiKey.isEmpty) missingCredentials.add('Algolia API Key');
    
    if (missingCredentials.isNotEmpty) {
      debugPrint('WARNING: Missing credentials: ${missingCredentials.join(', ')}');
      return false;
    }
    
    return true;
  }
  
  /// Checks if the Firebase service account file exists
  static bool hasFirebaseServiceAccount() {
    final file = File(firebaseServiceAccountPath);
    return file.existsSync();
  }
}
