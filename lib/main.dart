import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bond_app/core/config/env_config.dart';
import 'package:bond_app/app/app.dart';
import 'package:bond_app/firebase_options.dart';
import 'package:bond_app/core/di/service_locator.dart';
import 'package:bond_app/core/managers/location_manager.dart';
import 'package:bond_app/core/services/algolia_service.dart';
import 'package:get_it/get_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    // Web platform is currently not supported
    runApp(const UnsupportedPlatformApp());
    return;
  }
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize environment configuration
  await EnvConfig.initialize();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  
  // Initialize service locator
  await setupServiceLocator();
  
  // Initialize location services
  try {
    final locationManager = GetIt.I<LocationManager>();
    await locationManager.initialize();
    print('Location services initialized successfully');
  } catch (e) {
    print('Failed to initialize location services: $e');
  }
  
  // Initialize Algolia service
  try {
    final algoliaService = GetIt.I<AlgoliaService>();
    await algoliaService.initialize(
      appId: EnvConfig.algoliaAppId,
      apiKey: EnvConfig.algoliaApiKey,
    );
    print('Algolia services initialized successfully');
  } catch (e) {
    print('Failed to initialize Algolia services: $e');
  }
  
  runApp(const BondApp());
}

/// A placeholder app for unsupported platforms
class UnsupportedPlatformApp extends StatelessWidget {
  const UnsupportedPlatformApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bond',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
              SizedBox(height: 20),
              Text(
                'Web Platform Support',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'The web platform version of this app is currently under development. '
                  'Please use the mobile app for full functionality.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}