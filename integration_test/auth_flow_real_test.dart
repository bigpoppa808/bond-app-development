import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bond_app/features/auth/presentation/screens/login_screen.dart';
import 'package:bond_app/main.dart' as app;
import 'package:bond_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'dart:async';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Firebase with real configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  group('Authentication Flow Integration Tests with Real Firebase', () {
    testWidgets('App initializes with Firebase and shows login screen', 
        (WidgetTester tester) async {
      // Run the actual app
      app.main();
      
      // Wait for app to initialize and animations to complete
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

    testWidgets('Show validation errors with invalid inputs', 
        (WidgetTester tester) async {
      // Run the app
      app.main();
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
    });

    testWidgets('Attempt login with incorrect credentials shows error', 
        (WidgetTester tester) async {
      // Run the app
      app.main();
      await tester.pumpAndSettle();
      
      // Enter invalid credentials (valid format but non-existent account)
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'nonexistent@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrongpassword');
      
      // Tap login button
      await tester.tap(find.text('Login'));
      
      // Wait for auth attempt to complete (may take a moment)
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      
      // Verify error message is displayed (exact message may vary based on implementation)
      expect(find.textContaining('Invalid'), findsOneWidget);
    });

    testWidgets('Navigate to signup screen when tapping Sign Up', 
        (WidgetTester tester) async {
      // Run the app
      app.main();
      await tester.pumpAndSettle();
      
      // Tap the sign up link
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      
      // Verify navigation to signup screen (adjust based on your actual signup screen content)
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Navigate to forgot password screen when tapping Forgot Password', 
        (WidgetTester tester) async {
      // Run the app
      app.main();
      await tester.pumpAndSettle();
      
      // Tap the forgot password link
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      
      // Verify navigation to forgot password screen (adjust based on your actual screen content)
      expect(find.text('Reset Password'), findsOneWidget);
    });
  });
}
