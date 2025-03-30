import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_event.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_state.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<bool> _authStateSubscription;

  AuthBloc(this._authRepository) : super(AuthInitialState()) {
    on<AuthCheckStatusEvent>(_onAuthCheckStatus);
    on<AuthSignInEvent>(_onAuthSignIn);
    on<AuthSignUpEvent>(_onAuthSignUp);
    on<AuthSignOutEvent>(_onAuthSignOut);
    on<AuthForgotPasswordEvent>(_onAuthForgotPassword);

    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (isAuthenticated) {
        if (isAuthenticated) {
          add(AuthCheckStatusEvent());
        } else {
          emit(AuthUnauthenticatedState());
        }
      },
    );
  }

  Future<void> _onAuthCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final isSignedIn = await _authRepository.isSignedIn();
      if (isSignedIn) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticatedState(user: user));
        } else {
          emit(AuthUnauthenticatedState());
        }
      } else {
        emit(AuthUnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onAuthSignIn(
    AuthSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final user = await _authRepository.signIn(
        event.email,
        event.password,
      );
      emit(AuthAuthenticatedState(user: user));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onAuthSignUp(
    AuthSignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final user = await _authRepository.signUp(
        event.email,
        event.password,
      );
      emit(AuthAuthenticatedState(user: user));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onAuthSignOut(
    AuthSignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onAuthForgotPassword(
    AuthForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(AuthPasswordResetSentState(email: event.email));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
