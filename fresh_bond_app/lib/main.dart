import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/app/app.dart';
import 'package:fresh_bond_app/core/analytics/analytics_service.dart';
import 'package:fresh_bond_app/core/config/app_config.dart';
import 'package:fresh_bond_app/core/config/env_config.dart';
import 'package:fresh_bond_app/core/di/service_locator.dart';
import 'package:fresh_bond_app/core/network/connectivity_service.dart';
import 'package:fresh_bond_app/core/utils/error_handler.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_bloc.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_event.dart';
import 'package:fresh_bond_app/features/discover/domain/blocs/discover_bloc.dart';
import 'package:fresh_bond_app/features/notifications/domain/blocs/notification_bloc.dart';

void main() async {
  // Set up error handling zone
  runZonedGuarded(() async {
    // Ensure Flutter binding is initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Setup environment configuration
    // This internally initializes AppConfig with the appropriate environment
    EnvConfig.setupEnvironment();

    // Initialize service locator
    await ServiceLocator.initialize();
    
    // Initialize analytics (constructor already initializes it)
    final _ = AnalyticsService.instance;

    // Initialize connectivity service
    ConnectivityService.instance;
    
    // Log app start
    AppLogger.instance.i('App started in ${EnvConfig.currentEnvName} mode');

    // Run the app
    runApp(BondAppRoot()); 
  }, ErrorHandler.handleZoneError);
}

/// Root widget for the Bond app
class BondAppRoot extends StatelessWidget {
  /// Constructor
  BondAppRoot({Key? key}) : super(key: key); 

  @override
  Widget build(BuildContext context) {
    // Create auth bloc
    final authBloc = AuthBloc(
      ServiceLocator.authRepository,
    );
    
    // Check authentication status on app start
    authBloc.add(const AuthCheckStatusEvent());
    
    return MultiBlocProvider(
      providers: [
        // Auth BLoC
        BlocProvider<AuthBloc>(
          create: (context) => authBloc,
        ),
        
        // Discover BLoC
        BlocProvider<DiscoverBloc>(
          create: (context) => DiscoverBloc(
            connectionsRepository: ServiceLocator.connectionsRepository,
            logger: AppLogger.instance,
          ),
        ),
        
        // Notification BLoC
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            notificationRepository: ServiceLocator.notificationRepository,
            logger: AppLogger.instance,
          ),
        ),
        
        // Additional BLoCs can be added here
      ],
      child: BondApp(), 
    );
  }
}
