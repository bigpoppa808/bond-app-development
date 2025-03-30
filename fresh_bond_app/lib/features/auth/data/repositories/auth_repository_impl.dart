import 'dart:async';

import 'package:fresh_bond_app/core/network/firebase_api_service.dart';
import 'package:fresh_bond_app/features/auth/domain/models/user_model.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseApiService _apiService;
  final SharedPreferences _prefs;
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();

  // Keys for SharedPreferences
  static const String _userKey = 'user_data';
  static const String _idTokenKey = 'id_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiryTimeKey = 'expiry_time';

  AuthRepositoryImpl({
    required FirebaseApiService apiService,
    required SharedPreferences prefs,
  })  : _apiService = apiService,
        _prefs = prefs {
    // Initialize auth state
    isSignedIn().then((value) => _authStateController.add(value));
  }

  @override
  Stream<bool> get authStateChanges => _authStateController.stream;

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await _apiService.signIn(email, password);
      
      final user = UserModel.fromJson(response);
      
      // Save auth data
      await _saveAuthData(
        user: user,
        idToken: response['idToken'],
        refreshToken: response['refreshToken'],
        expiresIn: int.parse(response['expiresIn']),
      );
      
      _authStateController.add(true);
      return user;
    } catch (e) {
      _authStateController.add(false);
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password) async {
    try {
      final response = await _apiService.signUp(email, password);
      
      final user = UserModel.fromJson(response);
      
      // Save auth data
      await _saveAuthData(
        user: user,
        idToken: response['idToken'],
        refreshToken: response['refreshToken'],
        expiresIn: int.parse(response['expiresIn']),
      );
      
      _authStateController.add(true);
      return user;
    } catch (e) {
      _authStateController.add(false);
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_idTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_expiryTimeKey);
    
    _authStateController.add(false);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _apiService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;
    
    try {
      final Map<String, dynamic> userData = Map<String, dynamic>.from(
        Map.from(Uri.splitQueryString(userJson))
      );
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getIdToken() async {
    final expiryTimeStr = _prefs.getString(_expiryTimeKey);
    final refreshToken = _prefs.getString(_refreshTokenKey);
    final currentToken = _prefs.getString(_idTokenKey);
    
    if (expiryTimeStr == null || refreshToken == null) {
      return null;
    }
    
    final expiryTime = DateTime.parse(expiryTimeStr);
    final now = DateTime.now();
    
    // If token is still valid, return it
    if (expiryTime.isAfter(now) && currentToken != null) {
      return currentToken;
    }
    
    // Otherwise refresh the token
    try {
      final response = await _apiService.refreshToken(refreshToken);
      
      await _prefs.setString(_idTokenKey, response['id_token']);
      await _prefs.setString(_refreshTokenKey, response['refresh_token']);
      
      final expiresIn = int.parse(response['expires_in']);
      final newExpiryTime = DateTime.now().add(Duration(seconds: expiresIn));
      await _prefs.setString(_expiryTimeKey, newExpiryTime.toIso8601String());
      
      return response['id_token'];
    } catch (e) {
      // If refresh fails, sign out
      await signOut();
      return null;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    final user = await getCurrentUser();
    final token = await getIdToken();
    return user != null && token != null;
  }

  // Helper method to save authentication data
  Future<void> _saveAuthData({
    required UserModel user,
    required String idToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    // Save user data
    await _prefs.setString(_userKey, Uri(queryParameters: user.toJson()).query);
    
    // Save tokens
    await _prefs.setString(_idTokenKey, idToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);
    
    // Calculate and save expiry time
    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
    await _prefs.setString(_expiryTimeKey, expiryTime.toIso8601String());
  }
}
