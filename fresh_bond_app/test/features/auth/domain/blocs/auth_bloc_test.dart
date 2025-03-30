import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_bloc.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_event.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_state.dart';
import 'package:fresh_bond_app/features/auth/domain/models/user_model.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;
  
  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  final testUser = UserModel(
    uid: 'user123',
    email: testEmail,
    displayName: 'Test User',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    
    // Setup stream controller for auth state changes
    when(mockAuthRepository.authStateChanges).thenAnswer(
      (_) => Stream.fromIterable([false]),
    );
    
    authBloc = AuthBloc(mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitialState', () {
      expect(authBloc.state, isA<AuthInitialState>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, AuthUnauthenticatedState] when AuthCheckStatusEvent is added and user is not signed in',
      build: () {
        when(mockAuthRepository.isSignedIn()).thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckStatusEvent()),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthUnauthenticatedState>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.isSignedIn()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, AuthAuthenticatedState] when AuthCheckStatusEvent is added and user is signed in',
      build: () {
        when(mockAuthRepository.isSignedIn()).thenAnswer((_) async => true);
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckStatusEvent()),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthAuthenticatedState>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.isSignedIn()).called(1);
        verify(mockAuthRepository.getCurrentUser()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, AuthAuthenticatedState] when AuthSignInEvent is added and sign in succeeds',
      build: () {
        when(mockAuthRepository.signIn(testEmail, testPassword))
            .thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignInEvent(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthAuthenticatedState>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.signIn(testEmail, testPassword)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, AuthErrorState] when AuthSignInEvent is added and sign in fails',
      build: () {
        when(mockAuthRepository.signIn(testEmail, testPassword))
            .thenThrow(Exception('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignInEvent(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthErrorState>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.signIn(testEmail, testPassword)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, AuthAuthenticatedState] when AuthSignUpEvent is added and sign up succeeds',
      build: () {
        when(mockAuthRepository.signUp(testEmail, testPassword))
            .thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignUpEvent(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthAuthenticatedState>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.signUp(testEmail, testPassword)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, AuthErrorState] when AuthSignUpEvent is added and sign up fails',
      build: () {
        when(mockAuthRepository.signUp(testEmail, testPassword))
            .thenThrow(Exception('Email already exists'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignUpEvent(
        email: testEmail,
        password: testPassword,
      )),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthErrorState>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.signUp(testEmail, testPassword)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, AuthUnauthenticatedState] when AuthSignOutEvent is added',
      build: () {
        when(mockAuthRepository.signOut()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthSignOutEvent()),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthUnauthenticatedState>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.signOut()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, AuthPasswordResetSentState] when AuthForgotPasswordEvent is added',
      build: () {
        when(mockAuthRepository.sendPasswordResetEmail(testEmail))
            .thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthForgotPasswordEvent(email: testEmail)),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthPasswordResetSentState>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.sendPasswordResetEmail(testEmail)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, AuthErrorState] when AuthForgotPasswordEvent is added and it fails',
      build: () {
        when(mockAuthRepository.sendPasswordResetEmail(testEmail))
            .thenThrow(Exception('Email not found'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthForgotPasswordEvent(email: testEmail)),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthErrorState>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.sendPasswordResetEmail(testEmail)).called(1);
      },
    );
  });
}
