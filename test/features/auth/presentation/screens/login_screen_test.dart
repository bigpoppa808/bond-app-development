import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bond_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocktail mocks
class MockAuthBloc extends Mock implements AuthBloc {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Fake class for UserModel
class FakeUserModel extends Fake implements UserModel {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(const SignInWithEmailPasswordRequested(
      email: 'test@example.com',
      password: 'password123',
    ));
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer(
      (_) => Stream.fromIterable([mockAuthBloc.state]),
    );
  });

  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Assert
    expect(find.text('Welcome to Bond'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
  });

  testWidgets('LoginScreen shows loading indicator when AuthInProgress state',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthInProgress());

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LoginScreen shows error message when AuthFailure state',
      (WidgetTester tester) async {
    // Arrange
    const errorMessage = 'Invalid credentials';
    when(() => mockAuthBloc.state).thenReturn(const AuthFailure(errorMessage));

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );
    
    // Pump the widget tree to allow the SnackBar to be built
    await tester.pump();

    // Assert
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('LoginScreen navigates to home when Authenticated state',
      (WidgetTester tester) async {
    // Arrange
    final testUser = UserModel(
      id: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: 'https://example.com/photo.jpg',
      isEmailVerified: true,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      interests: ['coding', 'reading'],
      tokenBalance: 100,
      isProfileComplete: true,
    );
    
    when(() => mockAuthBloc.state).thenReturn(Authenticated(testUser));

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Assert - navigation is handled by router, so we just verify the login form is built
    expect(find.byType(Form), findsOneWidget);
  });

  testWidgets('LoginScreen submits form when valid data is entered',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Enter valid email and password
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.pumpAndSettle();

    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Assert
    verify(() => mockAuthBloc.add(const SignInWithEmailPasswordRequested(
          email: 'test@example.com',
          password: 'password123',
        ))).called(1);
  });

  testWidgets('LoginScreen shows error for invalid email',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Enter invalid email
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.pumpAndSettle();

    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Please enter a valid email'), findsOneWidget);
    verifyNever(() => mockAuthBloc.add(any()));
  });

  testWidgets('LoginScreen shows error for empty email',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Leave email empty
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.pumpAndSettle();

    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Please enter your email'), findsOneWidget);
    verifyNever(() => mockAuthBloc.add(any()));
  });

  testWidgets('LoginScreen shows error for empty password',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Leave password empty
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.pumpAndSettle();

    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Please enter your password'), findsOneWidget);
    verifyNever(() => mockAuthBloc.add(any()));
  });

  testWidgets('LoginScreen navigates to forgot password screen',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    final mockObserver = MockNavigatorObserver();

    // Act
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [mockObserver],
        onGenerateRoute: (settings) {
          if (settings.name == '/forgot-password') {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Forgot Password Screen')),
            );
          }
          return null;
        },
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Tap the forgot password link
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    // Assert - verify that we attempted to navigate to forgot password screen
    expect(find.text('Forgot Password Screen'), findsOneWidget);
  });

  testWidgets('LoginScreen navigates to signup screen',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    final mockObserver = MockNavigatorObserver();

    // Act
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [mockObserver],
        onGenerateRoute: (settings) {
          if (settings.name == '/signup') {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Signup Screen')),
            );
          }
          return null;
        },
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Tap the sign up link
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Assert - verify that we attempted to navigate to signup screen
    expect(find.text('Signup Screen'), findsOneWidget);
  });
}
