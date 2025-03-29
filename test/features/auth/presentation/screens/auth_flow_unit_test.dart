import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bond_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';

// Mock classes for testing
class MockAuthBloc extends Mock implements AuthBloc {
  final StreamController<AuthState> _stateController = StreamController<AuthState>.broadcast();
  AuthState _state = const AuthInitial();

  @override
  Stream<AuthState> get stream => _stateController.stream;

  @override
  AuthState get state => _state;

  @override
  void add(AuthEvent event) {
    super.noSuchMethod(Invocation.method(#add, [event]));
  }

  void mockState(AuthState state) {
    _state = state;
    _stateController.add(state);
  }

  @override
  Future<void> close() async {
    await _stateController.close();
    return super.noSuchMethod(Invocation.method(#close, []));
  }
}

class MockUserModel extends Mock implements UserModel {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Fake classes for fallback values
class FakeAuthEvent extends Fake implements AuthEvent {}
class FakeAuthState extends Fake implements AuthState {}
class FakeSignInWithEmailPasswordRequested extends Fake implements SignInWithEmailPasswordRequested {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    // Register fallback values
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeAuthState());
    registerFallbackValue(FakeSignInWithEmailPasswordRequested());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    // Setup default state
    mockAuthBloc.mockState(const AuthInitial());
  });

  tearDown(() {
    // Reset mocks after each test
    reset(mockAuthBloc);
  });

  group('Authentication Flow Tests', () {
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
      
      // Pump a few times instead of pumpAndSettle to avoid timeouts
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verify login screen elements are displayed
      expect(find.text('Welcome to Bond'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      
      // Verify form fields are present
      expect(find.byType(TextFormField), findsWidgets);
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
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Try to login with empty fields (just tap the login button)
      await tester.tap(find.text('Login'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verify validation errors for empty fields are present somewhere
      expect(find.text('Please enter your email'), findsOneWidget);
      
      // Explicitly verify that no auth event was triggered
      verifyNever(() => mockAuthBloc.add(any<AuthEvent>()));
    });

    testWidgets('Show loading indicator during authentication', (WidgetTester tester) async {
      // Setup auth bloc to show loading state
      mockAuthBloc.mockState(const AuthInProgress());
      
      // Build the login screen with mock bloc
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const LoginScreen(),
          ),
        ),
      );
      
      await tester.pump(); 
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verify loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Submit login form with valid credentials', (WidgetTester tester) async {
      // Create a completer to track when the add method is called
      final completer = Completer<void>();
      
      // Setup the mock to complete the completer when add is called
      when(() => mockAuthBloc.add(any<AuthEvent>())).thenAnswer((_) {
        completer.complete();
      });
      
      // Build the login screen with mock bloc
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const LoginScreen(),
          ),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Enter valid credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      
      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();
      
      // Wait for the bloc add method to be called
      await completer.future.timeout(const Duration(seconds: 1), onTimeout: () {
        // If timeout, we'll still check the verification
      });
      
      // Verify auth event was triggered
      verify(() => mockAuthBloc.add(any<AuthEvent>())).called(1);
    });
  });
}
