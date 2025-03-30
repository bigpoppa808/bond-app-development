import 'package:fresh_bond_app/core/config/app_config.dart';
import 'package:fresh_bond_app/core/network/connectivity_service.dart';
import 'package:fresh_bond_app/core/network/firebase_api_service.dart';
import 'package:fresh_bond_app/core/utils/error_handler.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/discover/data/repositories/connections_repository_impl.dart';
import 'package:fresh_bond_app/features/discover/domain/repositories/connections_repository.dart';
import 'package:fresh_bond_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:fresh_bond_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service locator for dependency injection
class ServiceLocator {
  static final GetIt _locator = GetIt.instance;
  
  /// Initialize the service locator
  static Future<void> initialize() async {
    // Register singletons
    final sharedPrefs = await SharedPreferences.getInstance();
    _locator.registerSingleton<SharedPreferences>(sharedPrefs);
    
    // Core services
    _locator.registerSingleton<AppLogger>(AppLogger.instance);
    _locator.registerSingleton<ErrorHandler>(ErrorHandler.instance);
    _locator.registerSingleton<ConnectivityService>(ConnectivityService.instance);
    
    // API services
    _locator.registerSingleton<FirebaseApiService>(
      FirebaseApiService(
        baseUrl: AppConfig.instance().apiBaseUrl, 
        apiKey: AppConfig.instance().firebaseApiKey,
      ),
    );
    
    // Repositories
    _locator.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(
        apiService: _locator<FirebaseApiService>(),
        prefs: _locator<SharedPreferences>(),
      ),
    );
    
    _locator.registerSingleton<ConnectionsRepository>(
      ConnectionsRepositoryImpl(
        apiService: _locator<FirebaseApiService>(),
        logger: _locator<AppLogger>(),
        errorHandler: _locator<ErrorHandler>(),
      ),
    );
    
    _locator.registerSingleton<NotificationRepository>(
      NotificationRepositoryImpl(
        apiService: _locator<FirebaseApiService>(),
        logger: _locator<AppLogger>(),
        errorHandler: _locator<ErrorHandler>(),
      ),
    );
  }
  
  /// Get the auth repository
  static AuthRepository get authRepository => _locator<AuthRepository>();
  
  /// Get the connections repository
  static ConnectionsRepository get connectionsRepository => _locator<ConnectionsRepository>();
  
  /// Get the notification repository
  static NotificationRepository get notificationRepository => _locator<NotificationRepository>();
  
  /// Reset the service locator (useful for testing)
  static void reset() {
    _locator.reset();
  }
}
