import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<dynamic>? _authSubscription;
  
  AuthBloc({required AuthRepository authRepository}) 
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInWithEmailPasswordRequested>(_onSignInWithEmailPasswordRequested);
    on<SignUpWithEmailPasswordRequested>(_onSignUpWithEmailPasswordRequested);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignInWithAppleRequested>(_onSignInWithAppleRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<EmailVerificationRequested>(_onEmailVerificationRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
  }
  
  /// Handle AuthCheckRequested event
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress());
    
    _authSubscription?.cancel();
    _authSubscription = _authRepository.user.listen(
      (user) {
        if (user != null) {
          add(UpdateProfileRequested(user: user));
        } else {
          emit(const Unauthenticated());
        }
      },
      onError: (error) {
        emit(AuthFailure(error.toString()));
      },
    );
  }
  
  /// Handle SignInWithEmailPasswordRequested event
  Future<void> _onSignInWithEmailPasswordRequested(
    SignInWithEmailPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress());
    
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        event.email, 
        event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
  
  /// Handle SignUpWithEmailPasswordRequested event
  Future<void> _onSignUpWithEmailPasswordRequested(
    SignUpWithEmailPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress());
    
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        event.email, 
        event.password, 
        event.displayName,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
  
  /// Handle SignInWithGoogleRequested event
  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress());
    
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
  
  /// Handle SignInWithAppleRequested event
  Future<void> _onSignInWithAppleRequested(
    SignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress());
    
    try {
      final user = await _authRepository.signInWithApple();
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
  
  /// Handle PasswordResetRequested event
  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress());
    
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(const PasswordResetSent());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
  
  /// Handle SignOutRequested event
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
  
  /// Handle EmailVerificationRequested event
  Future<void> _onEmailVerificationRequested(
    EmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.sendEmailVerification();
      emit(const EmailVerificationSent());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
  
  /// Handle UpdateProfileRequested event
  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final updatedUser = await _authRepository.updateUserProfile(event.user);
      emit(Authenticated(updatedUser));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
  
  /// Handle DeleteAccountRequested event
  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.deleteAccount();
      emit(const AccountDeleted());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
