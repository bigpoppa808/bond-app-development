import 'package:firebase_auth/firebase_auth.dart';
import 'package:bond_app/features/auth/data/models/user_model.dart';

/// Interface for authentication repository
abstract class AuthRepository {
  /// Get the current authenticated user
  Stream<UserModel?> get user;
  
  /// Get the current authentication state
  Stream<bool> get authStateChanges;
  
  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  
  /// Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword(String email, String password, String displayName);
  
  /// Sign in with Google
  Future<UserModel> signInWithGoogle();
  
  /// Sign in with Apple
  Future<UserModel> signInWithApple();
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);
  
  /// Sign out
  Future<void> signOut();
  
  /// Verify email
  Future<void> sendEmailVerification();
  
  /// Update user profile
  Future<UserModel> updateUserProfile(UserModel user);
  
  /// Delete user account
  Future<void> deleteAccount();
}
