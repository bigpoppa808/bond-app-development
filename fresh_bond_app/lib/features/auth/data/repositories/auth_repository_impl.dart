import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart' as firebase show User;
import 'package:fresh_bond_app/core/network/firebase_api_service.dart';
import 'package:fresh_bond_app/features/auth/data/firebase_auth_service.dart';
import 'package:fresh_bond_app/features/auth/domain/models/user_model.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseApiService _apiService;
  final SharedPreferences _prefs;
  final FirebaseAuthService _firebaseAuthService;
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();

  // Keys for SharedPreferences
  static const String _userKey = 'user_data';
  static const String _idTokenKey = 'id_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiryTimeKey = 'expiry_time';

  AuthRepositoryImpl({
    required FirebaseApiService apiService,
    required SharedPreferences prefs,
    required FirebaseAuthService firebaseAuthService,
  })  : _apiService = apiService,
        _prefs = prefs,
        _firebaseAuthService = firebaseAuthService {
    // Initialize auth state
    isSignedIn().then((value) => _authStateController.add(value));
    
    // Listen to Firebase auth state changes
    _firebaseAuthService.authStateChanges.listen((user) {
      _authStateController.add(user != null);
    });
  }

  @override
  Stream<bool> get authStateChanges => _authStateController.stream;

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      // Use Firebase auth service
      final user = await _firebaseAuthService.login(email, password);
      
      if (user == null) {
        throw Exception('User is null after sign in');
      }
      
      // Create user model
      final userModel = _mapFirebaseUserToUserModel(user);
      
      // Save user data
      await _saveUserData(userModel);
      
      // Update auth state
      _authStateController.add(true);
      
      return userModel;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password) async {
    try {
      // Use Firebase auth service for registration
      final user = await _firebaseAuthService.register(
        email: email,
        password: password,
        displayName: email.split('@').first, // Simple display name based on email
      );
      
      if (user == null) {
        throw Exception('User is null after sign up');
      }
      
      // Create user model
      final userModel = _mapFirebaseUserToUserModel(user);
      
      // Save user data
      await _saveUserData(userModel);
      
      // Update auth state
      _authStateController.add(true);
      
      return userModel;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuthService.signOut();
      await _clearAuthData();
      _authStateController.add(false);
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuthService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // Try to get user from Firebase
      final currentUser = _firebaseAuthService.currentUser;
      
      if (currentUser != null) {
        return _mapFirebaseUserToUserModel(currentUser);
      }
      
      // If not found in Firebase, try from SharedPreferences
      final userString = _prefs.getString(_userKey);
      if (userString == null) return null;
      
      final params = Uri.parse('?$userString').queryParameters;
      return UserModel.fromJson(params);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    // First check if Firebase has a current user
    if (_firebaseAuthService.currentUser != null) {
      return true;
    }
    
    // Otherwise check our stored user data
    final user = await getCurrentUser();
    return user != null;
  }

  @override
  Future<String?> getIdToken() async {
    // Check if we have a cached token that's still valid
    final tokenExpiry = _prefs.getInt(_expiryTimeKey);
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    if (tokenExpiry != null && tokenExpiry > currentTime) {
      // Token is still valid
      return _prefs.getString(_idTokenKey);
    }
    
    // Get fresh token from Firebase Auth
    try {
      final user = _firebaseAuthService.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        
        if (token != null) {
          // Cache the token
          await _prefs.setString(_idTokenKey, token);
          
          // Set expiry to 1 hour from now
          final expiryTime = DateTime.now().millisecondsSinceEpoch + 3600000;
          await _prefs.setInt(_expiryTimeKey, expiryTime);
        }
        
        return token;
      }
      
      return null;
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  // Helper method to convert Firebase User to UserModel
  UserModel _mapFirebaseUserToUserModel(firebase.User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
      lastLoginAt: user.metadata.lastSignInTime,
      additionalUserInfo: {
        'providerId': user.providerData.isNotEmpty 
            ? user.providerData.first.providerId 
            : 'firebase',
      },
    );
  }

  // Helper method to save user data
  Future<void> _saveUserData(UserModel userModel) async {
    // Save user data
    await _prefs.setString(_userKey, Uri(queryParameters: userModel.toJson()).query);
  }

  // Helper method to clear auth data
  Future<void> _clearAuthData() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_idTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_expiryTimeKey);
  }
}
