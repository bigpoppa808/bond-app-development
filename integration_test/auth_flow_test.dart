import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bond_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes for testing
class MockAuthBloc extends Mock implements AuthBloc {}
class MockUserModel extends Mock implements UserModel {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthBloc mockAuthBloc;

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
  });
}
