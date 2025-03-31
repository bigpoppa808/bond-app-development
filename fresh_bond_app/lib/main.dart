import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/app/app.dart';
import 'package:fresh_bond_app/core/config/app_config.dart';
import 'package:fresh_bond_app/core/di/service_locator.dart';
import 'package:fresh_bond_app/features/auth/data/firebase_auth_service.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/nfc_verification/nfc_verification_bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/nfc_verification_repository_interface.dart';
import 'package:fresh_bond_app/features/notifications/domain/blocs/notification_bloc.dart';
import 'package:fresh_bond_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:fresh_bond_app/features/token_economy/domain/blocs/achievement_bloc.dart';
import 'package:fresh_bond_app/features/token_economy/domain/blocs/token_bloc.dart';
import 'package:fresh_bond_app/features/token_economy/domain/repositories/achievement_repository.dart';
import 'package:fresh_bond_app/features/token_economy/domain/repositories/token_repository.dart';
import 'package:fresh_bond_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AppConfig first
  AppConfig.initialize(environment: Environment.development);
  
  // Initialize Firebase with a try-catch to handle potential errors
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Continue anyway for development purposes
  }
  
  // Initialize service locator
  await ServiceLocator.initialize();
  
  // Create a test account for development
  final firebaseAuthService = ServiceLocator.getIt<FirebaseAuthService>();
  try {
    await firebaseAuthService.createTestAccount();
    print('Test account created/verified successfully');
  } catch (e) {
    print('Error creating test account: $e');
  }
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: ServiceLocator.getIt<AuthRepository>(),
          ),
        ),
        BlocProvider<MeetingBloc>(
          create: (context) => MeetingBloc(
            meetingRepository: ServiceLocator.getIt<MeetingRepository>(),
          ),
        ),
        BlocProvider<NfcVerificationBloc>(
          create: (context) => NfcVerificationBloc(
            nfcRepository: ServiceLocator.getIt<NfcVerificationRepositoryInterface>(),
          ),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            notificationRepository: ServiceLocator.getIt<NotificationRepository>(),
            logger: ServiceLocator.getIt.get<AppLogger>()
          ),
        ),
        BlocProvider<TokenBloc>(
          create: (context) => TokenBloc(
            tokenRepository: ServiceLocator.getIt<TokenRepository>(),
          ),
        ),
        BlocProvider<AchievementBloc>(
          create: (context) => AchievementBloc(
            achievementRepository: ServiceLocator.getIt<AchievementRepository>(),
          ),
        ),
      ],
      child: BondApp(),
    ),
  );
}
