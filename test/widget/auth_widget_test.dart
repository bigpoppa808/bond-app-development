import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bond_app/firebase_options.dart';
import 'package:flutter/services.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserModel extends Mock implements UserModel {}
class FakeUserModel extends Fake implements UserModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late MockAuthRepository mockAuthRepository;

  setUpAll(() async {
    // Register fallback values for Mocktail
    registerFallbackValue(FakeUserModel());
    
    // Mock the Firebase.initializeApp method to return a Future that completes successfully
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      MethodChannel('plugins.flutter.io/firebase_core'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'Firebase#initializeApp') {
          return {
            'name': 'test',
            'options': {
              'apiKey': 'test-api-key',
              'appId': 'test-app-id',
              'messagingSenderId': 'test-messaging-sender-id',
              'projectId': 'test-project-id',
            },
          };
        }
        return null;
      },
    );
    
    // Initialize Firebase for testing
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Firebase initialization will likely fail in tests, but that's ok for UI testing
      print('Firebase initialization failed: $e');
    }
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('Login Screen Widget Tests', () {
    testWidgets('renders login form fields', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: mockAuthRepository),
            child: const LoginScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeast(2)); // Email and password fields
      expect(find.byType(ElevatedButton), findsOneWidget); // Login button
    });

    testWidgets('shows validation errors for empty fields', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: mockAuthRepository),
            child: const LoginScreen(),
          ),
        ),
      );
      
      // Act - tap the login button without entering any data
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Assert - validation error messages should be visible
      expect(find.text('Email cannot be empty'), findsOneWidget);
      expect(find.text('Password cannot be empty'), findsOneWidget);
    });

    testWidgets('submits valid form data to auth bloc', (WidgetTester tester) async {
      // Arrange
      final mockUser = MockUserModel();
      when(() => mockAuthRepository.signInWithEmailAndPassword('test@example.com', 'password123'))
          .thenAnswer((_) async => mockUser);
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: mockAuthRepository),
            child: const LoginScreen(),
          ),
        ),
      );
      
      // Act - enter valid data and submit
      await tester.enterText(find.byKey(const Key('emailField')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Assert - verify the auth repository was called with correct parameters
      verify(() => mockAuthRepository.signInWithEmailAndPassword('test@example.com', 'password123')).called(1);
    });
  });
}
