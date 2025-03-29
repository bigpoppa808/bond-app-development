import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bond_app/features/auth/presentation/screens/login_screen.dart';
import 'package:bond_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/firebase_test_helper.dart';

// Mock classes for testing
class MockAuthBloc extends Mock implements AuthBloc {}
class MockUserModel extends Mock implements UserModel {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthBloc mockAuthBloc;
  
  setUpAll(() async {
    // Initialize Firebase for testing
    await FirebaseTestHelper.setupFirebase();
  });
  
  tearDownAll(() async {
    // Clean up after tests
    await FirebaseTestHelper.cleanup();
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    // Setup default state
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
  });

  group('Authentication Flow Integration Tests', () {
    testWidgets('Login screen renders correctly', (WidgetTester tester) async {
      // Build the login screen with mock bloc
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const LoginScreen(),
          ),
        ),
      );
      
      // Wait for all animations to complete
      await tester.pumpAndSettle();
      
      // Verify login screen elements are displayed
      expect(find.text('Welcome to Bond'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      
      // Verify form fields are present
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    });

    testWidgets('Show validation errors with invalid inputs', (WidgetTester tester) async {
      // Build the login screen with mock bloc
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Try to login with empty fields (just tap the login button)
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Verify validation errors for empty fields
      expect(find.text('Please enter your email'), findsOneWidget);
      
      // Now try with invalid email format
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Verify email validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
      
      // Verify no auth event was triggered for invalid inputs
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('Show loading indicator during authentication', (WidgetTester tester) async {
      // Setup auth bloc to show loading state
      when(() => mockAuthBloc.state).thenReturn(const AuthInProgress());
      
      // Build the login screen with mock bloc
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Verify login button is disabled during loading
      final buttonFinder = find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(ElevatedButton),
      );
      expect(buttonFinder, findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull); // Button should be disabled
    });

    testWidgets('Show error message on authentication failure', (WidgetTester tester) async {
      // First setup initial state
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
      
      // Build the login screen with mock bloc
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Enter valid credentials
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      
      // Setup the bloc to handle the sign-in attempt and fail
      when(() => mockAuthBloc.add(any(that: isA<SignInWithEmailPasswordRequested>())))
          .thenAnswer((_) {
        // Change state to show error after login attempt
        when(() => mockAuthBloc.state).thenReturn(const AuthFailure('Invalid credentials'));
      });
      
      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Verify auth event was triggered
      verify(() => mockAuthBloc.add(any(that: isA<SignInWithEmailPasswordRequested>()))).called(1);
      
      // Now simulate the state change to failure
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const LoginScreen(),
          ),
        ),
      );
      
      await tester.pump(); // Pump once to show the SnackBar
      
      // Verify error message is displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('Navigate to signup screen when tapping Sign Up', (WidgetTester tester) async {
      // Build the login screen with mock bloc
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => BlocProvider<AuthBloc>.value(
                  value: mockAuthBloc,
                  child: const LoginScreen(),
                ),
            '/signup': (context) => const Scaffold(body: Text('Signup Screen')),
          },
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap the sign up link
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      
      // Verify navigation to signup screen
      expect(find.text('Signup Screen'), findsOneWidget);
    });

    testWidgets('Navigate to forgot password screen when tapping Forgot Password', (WidgetTester tester) async {
      // Build the login screen with mock bloc
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => BlocProvider<AuthBloc>.value(
                  value: mockAuthBloc,
                  child: const LoginScreen(),
                ),
            '/forgot-password': (context) => const Scaffold(body: Text('Forgot Password Screen')),
          },
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap the forgot password link
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      
      // Verify navigation to forgot password screen
      expect(find.text('Forgot Password Screen'), findsOneWidget);
    });

    testWidgets('Successfully login and navigate to home screen', (WidgetTester tester) async {
      // Create a test user
      final testUser = UserModel(
        id: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        interests: ['coding', 'flutter'],
        tokenBalance: 100,
        isProfileComplete: true,
      );
      
      // First setup initial state
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
      
      // Build the login screen with mock bloc and navigation
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => BlocProvider<AuthBloc>.value(
                  value: mockAuthBloc,
                  child: const LoginScreen(),
                ),
            '/home': (context) => const Scaffold(body: Text('Home Screen')),
          },
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Enter valid credentials
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      
      // Setup the bloc to handle the sign-in attempt and succeed
      when(() => mockAuthBloc.add(any(that: isA<SignInWithEmailPasswordRequested>())))
          .thenAnswer((_) {
        // Change state to authenticated after login attempt
        when(() => mockAuthBloc.state).thenReturn(Authenticated(testUser));
      });
      
      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Verify auth event was triggered
      verify(() => mockAuthBloc.add(any(that: isA<SignInWithEmailPasswordRequested>()))).called(1);
      
      // Now simulate the state change to authenticated
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => BlocProvider<AuthBloc>.value(
                  value: mockAuthBloc,
                  child: const LoginScreen(),
                ),
            '/home': (context) => const Scaffold(body: Text('Home Screen')),
          },
          builder: (context, child) {
            return BlocListener<AuthBloc, AuthState>(
              bloc: mockAuthBloc,
              listener: (context, state) {
                if (state is Authenticated) {
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              },
              child: child,
            );
          },
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify navigation to home screen
      expect(find.text('Home Screen'), findsOneWidget);
    });
  });
}
