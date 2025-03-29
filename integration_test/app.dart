import 'package:bond_app/firebase_options.dart';
import 'package:bond_app/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// This is the main entry point for integration tests.
/// It initializes Firebase with the real configuration from your project.
Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with the actual project configuration
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run the app
  app.main();
}
