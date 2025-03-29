import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserModel extends Mock implements UserModel {}
class FakeUserModel extends Fake implements UserModel {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late StreamController<UserModel?> userStreamController;
  late StreamController<bool> authStateStreamController;

  setUpAll(() {
    // Register fallback values for Mocktail
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    userStreamController = StreamController<UserModel?>.broadcast();
    authStateStreamController = StreamController<bool>.broadcast();
    
    // Setup the mock repository
    when(() => mockAuthRepository.user).thenAnswer((_) => userStreamController.stream);
    when(() => mockAuthRepository.authStateChanges).thenAnswer((_) => authStateStreamController.stream);
    
    // Create the auth bloc with the mock repository
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
    userStreamController.close();
    authStateStreamController.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(const AuthInitial()));
    });

    test('emits AuthInProgress and Authenticated when SignInWithEmailPasswordRequested is successful', () async {
      // Arrange
      final mockUser = MockUserModel();
      when(() => mockAuthRepository.signInWithEmailAndPassword('test@example.com', 'password123'))
          .thenAnswer((_) async => mockUser);
      
      // Act
      authBloc.add(const SignInWithEmailPasswordRequested(
        email: 'test@example.com',
        password: 'password123',
      ));
      
      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthInProgress(),
          Authenticated(mockUser),
        ]),
      );
    });

    test('emits AuthInProgress and AuthFailure when SignInWithEmailPasswordRequested fails', () async {
      // Arrange
      when(() => mockAuthRepository.signInWithEmailAndPassword('test@example.com', 'wrongpassword'))
          .thenThrow(Exception('Invalid credentials'));
      
      // Act
      authBloc.add(const SignInWithEmailPasswordRequested(
        email: 'test@example.com',
        password: 'wrongpassword',
      ));
      
      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthInProgress(),
          predicate<AuthState>((state) => 
            state is AuthFailure && state.message.contains('Invalid credentials')
          ),
        ]),
      );
    });

    test('emits AuthInProgress and Authenticated when SignUpWithEmailPasswordRequested is successful', () async {
      // Arrange
      final mockUser = MockUserModel();
      when(() => mockAuthRepository.signUpWithEmailAndPassword('new@example.com', 'password123', 'New User'))
          .thenAnswer((_) async => mockUser);
      
      // Act
      authBloc.add(const SignUpWithEmailPasswordRequested(
        email: 'new@example.com',
        password: 'password123',
        displayName: 'New User',
      ));
      
      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthInProgress(),
          Authenticated(mockUser),
        ]),
      );
    });

    test('emits AuthInProgress and AuthFailure when SignUpWithEmailPasswordRequested fails', () async {
      // Arrange
      when(() => mockAuthRepository.signUpWithEmailAndPassword('existing@example.com', 'password123', 'Existing User'))
          .thenThrow(Exception('Email already in use'));
      
      // Act
      authBloc.add(const SignUpWithEmailPasswordRequested(
        email: 'existing@example.com',
        password: 'password123',
        displayName: 'Existing User',
      ));
      
      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthInProgress(),
          predicate<AuthState>((state) => 
            state is AuthFailure && state.message.contains('Email already in use')
          ),
        ]),
      );
    });

    test('emits Unauthenticated when SignOutRequested is successful', () async {
      // Arrange
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
      
      // Act
      authBloc.add(const SignOutRequested());
      
      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const Unauthenticated(),
        ]),
      );
    });

    test('emits AuthFailure when SignOutRequested fails', () async {
      // Arrange
      when(() => mockAuthRepository.signOut()).thenThrow(Exception('Sign out failed'));
      
      // Act
      authBloc.add(const SignOutRequested());
      
      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          predicate<AuthState>((state) => 
            state is AuthFailure && state.message.contains('Sign out failed')
          ),
        ]),
      );
    });

    test('emits AuthInProgress and Authenticated when SignInWithGoogleRequested is successful', () async {
      // Arrange
      final mockUser = MockUserModel();
      when(() => mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => mockUser);
      
      // Act
      authBloc.add(const SignInWithGoogleRequested());
      
      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthInProgress(),
          Authenticated(mockUser),
        ]),
      );
    });

    test('emits AuthInProgress and AuthFailure when SignInWithGoogleRequested fails', () async {
      // Arrange
      when(() => mockAuthRepository.signInWithGoogle())
          .thenThrow(Exception('Google sign in failed'));
      
      // Act
      authBloc.add(const SignInWithGoogleRequested());
      
      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthInProgress(),
          predicate<AuthState>((state) => 
            state is AuthFailure && state.message.contains('Google sign in failed')
          ),
        ]),
      );
    });
  });
}
