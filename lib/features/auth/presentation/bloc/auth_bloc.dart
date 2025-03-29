import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bond_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:bond_app/core/services/location_tracking_service.dart';
import 'package:get_it/get_it.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ProfileRepository? _profileRepository;
  final LocationTrackingService _locationTrackingService;
  StreamSubscription<dynamic>? _authSubscription;
  
  AuthBloc({
    required AuthRepository authRepository, 
    ProfileRepository? profileRepository,
    LocationTrackingService? locationTrackingService,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository,
       _locationTrackingService = locationTrackingService ?? GetIt.I<LocationTrackingService>(),
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
      
      // Check if user has a profile, if not create one
      await _ensureUserHasProfile(user.uid);
      
      // Start location tracking for the user
      await _locationTrackingService.startTracking(user.uid);
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
      
      // Create a profile for the new user
      await _createUserProfile(user.uid, user.displayName, user.email);
      
      // Start location tracking for the new user
      await _locationTrackingService.startTracking(user.uid);
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
      
      // Check if user has a profile, if not create one
      await _ensureUserHasProfile(user.uid, user.displayName, user.email, user.photoUrl);
      
      // Start location tracking for the user
      await _locationTrackingService.startTracking(user.uid);
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
      
      // Check if user has a profile, if not create one
      await _ensureUserHasProfile(user.uid, user.displayName, user.email);
      
      // Start location tracking for the user
      await _locationTrackingService.startTracking(user.uid);
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
      emit(const PasswordResetEmailSent());
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
      // Stop location tracking before signing out
      await _locationTrackingService.stopTracking();
      
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
      // Get the user ID before deleting the account
      final userId = (state as Authenticated).user.uid;
      
      // Stop location tracking
      await _locationTrackingService.stopTracking();
      
      // Delete the user's profile if profile repository is available
      if (_profileRepository != null) {
        await _profileRepository!.deleteProfile(userId);
      }
      
      // Delete the user account
      await _authRepository.deleteAccount();
      emit(const AccountDeleted());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
  
  /// Ensure that a user has a profile, creating one if needed
  Future<void> _ensureUserHasProfile(
    String userId, [
    String? displayName,
    String? email,
    String? photoUrl,
  ]) async {
    if (_profileRepository == null) return;
    
    try {
      // Check if profile exists
      final existingProfile = await _profileRepository!.getProfile(userId);
      
      if (existingProfile == null) {
        // Create a new profile if none exists
        await _createUserProfile(userId, displayName, email, photoUrl);
      }
    } catch (e) {
      print('Error ensuring user profile: $e');
    }
  }
  
  /// Create a new user profile
  Future<void> _createUserProfile(
    String userId, [
    String? displayName,
    String? email,
    String? photoUrl,
  ]) async {
    if (_profileRepository == null) return;
    
    try {
      final newProfile = ProfileModel.create(userId: userId)
          .copyWith(
            displayName: displayName,
            email: email,
            photoUrl: photoUrl != null ? [photoUrl] : null,
            isPublic: true,
            lastUpdated: DateTime.now(),
          );
      
      await _profileRepository!.createProfile(newProfile);
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }
  
  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
