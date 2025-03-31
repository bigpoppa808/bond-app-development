import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fresh_bond_app/core/config/app_config.dart';
import 'package:fresh_bond_app/core/network/connectivity_service.dart';
import 'package:fresh_bond_app/core/network/firebase_api_service.dart';
import 'package:fresh_bond_app/core/utils/error_handler.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/features/auth/data/firebase_auth_service.dart';
import 'package:fresh_bond_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/discover/data/repositories/connections_repository_impl.dart';
import 'package:fresh_bond_app/features/discover/domain/repositories/connections_repository.dart';
import 'package:fresh_bond_app/features/meetings/data/repositories/meeting_repository_impl.dart';
import 'package:fresh_bond_app/features/meetings/data/repositories/nfc_verification_repository.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/nfc_verification_repository_interface.dart';
import 'package:fresh_bond_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:fresh_bond_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service locator for dependency injection
class ServiceLocator {
  static final GetIt _locator = GetIt.instance;
  
  /// Get the service locator instance
  static GetIt get getIt => _locator;
  
  /// Initialize the service locator
  static Future<void> initialize() async {
    // Register singletons
    final sharedPrefs = await SharedPreferences.getInstance();
    _locator.registerSingleton<SharedPreferences>(sharedPrefs);
    
    // Core services
    _locator.registerSingleton<AppLogger>(AppLogger.instance);
    _locator.registerSingleton<ErrorHandler>(ErrorHandler.instance);
    _locator.registerSingleton<ConnectivityService>(ConnectivityService.instance);
    
    // Auth Services - Using real Firebase service
    _locator.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
    
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
        firebaseAuthService: _locator<FirebaseAuthService>(),
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
    
    // Register Meeting Repository
    _locator.registerSingleton<MeetingRepository>(
      MeetingRepositoryImpl(
        firestore: FirebaseFirestore.instance,
        authRepository: _locator<AuthRepository>(),
        logger: _locator<AppLogger>(),
        errorHandler: _locator<ErrorHandler>(),
      ),
    );
    
    // Register NFC Manager and Verification Repository
    try {
      final nfcManager = NfcManager.instance;
      _locator.registerSingleton<NfcManager>(nfcManager);
      
      _locator.registerSingleton<NfcVerificationRepositoryInterface>(
        NfcVerificationRepository(
          nfcManager: _locator<NfcManager>(),
          authRepository: _locator<AuthRepository>(),
          meetingRepository: _locator<MeetingRepository>(),
          logger: _locator<AppLogger>(),
          errorHandler: _locator<ErrorHandler>(),
        ),
      );
    } catch (e) {
      // Log NFC initialization error but don't crash the app
      _locator<AppLogger>().e('Error initializing NFC: $e');
      
      // Register a dummy NFC verification repository that will report NFC as unavailable
      _locator.registerSingleton<NfcVerificationRepositoryInterface>(
        NfcVerificationRepository(
          nfcManager: NfcManager.instance,
          authRepository: _locator<AuthRepository>(),
          meetingRepository: _locator<MeetingRepository>(),
          logger: _locator<AppLogger>(),
          errorHandler: _locator<ErrorHandler>(),
        ),
      );
    }
  }
  
  /// Get the auth repository
  static AuthRepository get authRepository => _locator<AuthRepository>();
  
  /// Get the connections repository
  static ConnectionsRepository get connectionsRepository => _locator<ConnectionsRepository>();
  
  /// Get the notification repository
  static NotificationRepository get notificationRepository => _locator<NotificationRepository>();
  
  /// Get the meeting repository
  static MeetingRepository get meetingRepository => _locator<MeetingRepository>();
  
  /// Get the NFC verification repository
  static NfcVerificationRepositoryInterface get nfcVerificationRepository => _locator<NfcVerificationRepositoryInterface>();
  
  /// Reset the service locator (useful for testing)
  static void reset() {
    _locator.reset();
  }
}
