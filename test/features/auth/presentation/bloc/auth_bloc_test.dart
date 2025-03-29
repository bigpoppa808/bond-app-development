import 'package:bloc_test/bloc_test.dart';
import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocktail mock
class MockAuthRepository extends Mock implements AuthRepository {}

// Fake class for UserModel
class FakeUserModel extends Fake implements UserModel {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue('dummy-string');
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

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

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInProgress, Authenticated] when AuthCheckRequested is added and user is logged in',
      build: () {
        // Setup a stream that emits a user
        final userStream = Stream<UserModel?>.value(testUser);
        when(() => mockAuthRepository.user).thenAnswer((_) => userStream);
        when(() => mockAuthRepository.updateUserProfile(any()))
            .thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        isA<AuthInProgress>(),
        isA<Authenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInProgress, Unauthenticated] when AuthCheckRequested is added and user is not logged in',
      build: () {
        // Setup a stream that emits null (no user)
        final userStream = Stream<UserModel?>.value(null);
        when(() => mockAuthRepository.user).thenAnswer((_) => userStream);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        isA<AuthInProgress>(),
        isA<Unauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInProgress, Authenticated] when SignInWithEmailPasswordRequested is added and sign in is successful',
      build: () {
        when(() => mockAuthRepository.signInWithEmailAndPassword(
          any(), any()
        )).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInWithEmailPasswordRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        isA<AuthInProgress>(),
        isA<Authenticated>(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signInWithEmailAndPassword(
          'test@example.com',
          'password123',
        )).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInProgress, AuthFailure] when SignInWithEmailPasswordRequested is added and sign in fails',
      build: () {
        when(() => mockAuthRepository.signInWithEmailAndPassword(
          any(), any()
        )).thenThrow(Exception('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInWithEmailPasswordRequested(
        email: 'test@example.com',
        password: 'wrong-password',
      )),
      expect: () => [
        isA<AuthInProgress>(),
        isA<AuthFailure>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInProgress, Authenticated] when SignUpWithEmailPasswordRequested is added and sign up is successful',
      build: () {
        when(() => mockAuthRepository.signUpWithEmailAndPassword(
          any(), any(), any()
        )).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignUpWithEmailPasswordRequested(
        email: 'new@example.com',
        password: 'password123',
        displayName: 'New User',
      )),
      expect: () => [
        isA<AuthInProgress>(),
        isA<Authenticated>(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signUpWithEmailAndPassword(
          'new@example.com',
          'password123',
          'New User',
        )).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInProgress, AuthFailure] when SignUpWithEmailPasswordRequested is added and sign up fails',
      build: () {
        when(() => mockAuthRepository.signUpWithEmailAndPassword(
          any(), any(), any()
        )).thenThrow(Exception('Email already in use'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignUpWithEmailPasswordRequested(
        email: 'existing@example.com',
        password: 'password123',
        displayName: 'Existing User',
      )),
      expect: () => [
        isA<AuthInProgress>(),
        isA<AuthFailure>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInProgress, Authenticated] when SignInWithGoogleRequested is added and sign in is successful',
      build: () {
        when(() => mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInWithGoogleRequested()),
      expect: () => [
        isA<AuthInProgress>(),
        isA<Authenticated>(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signInWithGoogle()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInProgress, AuthFailure] when SignInWithGoogleRequested is added and sign in fails',
      build: () {
        when(() => mockAuthRepository.signInWithGoogle())
            .thenThrow(Exception('Google sign in failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInWithGoogleRequested()),
      expect: () => [
        isA<AuthInProgress>(),
        isA<AuthFailure>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInProgress, Authenticated] when SignInWithAppleRequested is added and sign in is successful',
      build: () {
        when(() => mockAuthRepository.signInWithApple())
            .thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInWithAppleRequested()),
      expect: () => [
        isA<AuthInProgress>(),
        isA<Authenticated>(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signInWithApple()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInProgress, AuthFailure] when SignInWithAppleRequested is added and sign in fails',
      build: () {
        when(() => mockAuthRepository.signInWithApple())
            .thenThrow(Exception('Apple sign in failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInWithAppleRequested()),
      expect: () => [
        isA<AuthInProgress>(),
        isA<AuthFailure>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInProgress, PasswordResetSent] when PasswordResetRequested is added and reset is successful',
      build: () {
        when(() => mockAuthRepository.sendPasswordResetEmail(any()))
            .thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const PasswordResetRequested(
        email: 'test@example.com',
      )),
      expect: () => [
        isA<AuthInProgress>(),
        isA<PasswordResetSent>(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.sendPasswordResetEmail('test@example.com')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInProgress, AuthFailure] when PasswordResetRequested is added and reset fails',
      build: () {
        when(() => mockAuthRepository.sendPasswordResetEmail(any()))
            .thenThrow(Exception('No user found with that email'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const PasswordResetRequested(
        email: 'nonexistent@example.com',
      )),
      expect: () => [
        isA<AuthInProgress>(),
        isA<AuthFailure>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when SignOutRequested is added and sign out is successful',
      build: () {
        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignOutRequested()),
      expect: () => [
        isA<Unauthenticated>(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signOut()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthFailure] when SignOutRequested is added and sign out fails',
      build: () {
        when(() => mockAuthRepository.signOut())
            .thenThrow(Exception('Sign out failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignOutRequested()),
      expect: () => [
        isA<AuthFailure>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [EmailVerificationSent] when EmailVerificationRequested is added and email is sent successfully',
      build: () {
        when(() => mockAuthRepository.sendEmailVerification())
            .thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const EmailVerificationRequested()),
      expect: () => [
        isA<EmailVerificationSent>(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.sendEmailVerification()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthFailure] when EmailVerificationRequested is added and email fails to send',
      build: () {
        when(() => mockAuthRepository.sendEmailVerification())
            .thenThrow(Exception('Failed to send email verification'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const EmailVerificationRequested()),
      expect: () => [
        isA<AuthFailure>(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.sendEmailVerification()).called(1);
      },
    );
  });
}
