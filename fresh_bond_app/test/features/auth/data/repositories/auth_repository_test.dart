import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_bond_app/core/network/firebase_api_service.dart';
import 'package:fresh_bond_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fresh_bond_app/features/auth/domain/models/user_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_repository_test.mocks.dart';

// Generate mocks
@GenerateMocks([FirebaseApiService, SharedPreferences])
void main() {
  late MockFirebaseApiService mockApiService;
  late MockSharedPreferences mockPrefs;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    mockApiService = MockFirebaseApiService();
    mockPrefs = MockSharedPreferences();
    authRepository = AuthRepositoryImpl(
      apiService: mockApiService,
      prefs: mockPrefs,
    );
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  
  final testAuthResponse = {
    'localId': 'user123',
    'email': testEmail,
    'idToken': 'test_id_token',
    'refreshToken': 'test_refresh_token',
    'expiresIn': '3600',
  };

  group('AuthRepository', () {
    test('signIn should return UserModel on successful sign in', () async {
      // Arrange
      when(mockApiService.signIn(testEmail, testPassword))
          .thenAnswer((_) async => testAuthResponse);
      
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      
      // Act
      final result = await authRepository.signIn(testEmail, testPassword);
      
      // Assert
      expect(result, isA<UserModel>());
      expect(result.email, testEmail);
      expect(result.uid, 'user123');
      
      // Verify SharedPreferences were updated
      verify(mockPrefs.setString(any, any)).called(4);
    });

    test('signUp should return UserModel on successful sign up', () async {
      // Arrange
      when(mockApiService.signUp(testEmail, testPassword))
          .thenAnswer((_) async => testAuthResponse);
      
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      
      // Act
      final result = await authRepository.signUp(testEmail, testPassword);
      
      // Assert
      expect(result, isA<UserModel>());
      expect(result.email, testEmail);
      expect(result.uid, 'user123');
      
      // Verify SharedPreferences were updated
      verify(mockPrefs.setString(any, any)).called(4);
    });

    test('signOut should clear stored user data', () async {
      // Arrange
      when(mockPrefs.remove(any)).thenAnswer((_) async => true);
      
      // Act
      await authRepository.signOut();
      
      // Assert
      verify(mockPrefs.remove(any)).called(4);
    });

    test('getCurrentUser should return null when no user is stored', () async {
      // Arrange
      when(mockPrefs.getString(any)).thenReturn(null);
      
      // Act
      final result = await authRepository.getCurrentUser();
      
      // Assert
      expect(result, isNull);
    });

    test('isSignedIn should return true when user and token are valid', () async {
      // Arrange
      // Mock a stored user
      final userJson = 'uid=user123&email=test%40example.com';
      when(mockPrefs.getString('user_data')).thenReturn(userJson);
      
      // Mock a valid token
      when(mockPrefs.getString('id_token')).thenReturn('valid_token');
      when(mockPrefs.getString('expiry_time'))
          .thenReturn(DateTime.now().add(const Duration(hours: 1)).toIso8601String());
      
      // Act
      final result = await authRepository.isSignedIn();
      
      // Assert
      expect(result, isTrue);
    });

    test('isSignedIn should return false when token is expired', () async {
      // Arrange
      // Mock a stored user
      final userJson = 'uid=user123&email=test%40example.com';
      when(mockPrefs.getString('user_data')).thenReturn(userJson);
      
      // Mock an expired token
      when(mockPrefs.getString('id_token')).thenReturn('expired_token');
      when(mockPrefs.getString('expiry_time'))
          .thenReturn(DateTime.now().subtract(const Duration(hours: 1)).toIso8601String());
      when(mockPrefs.getString('refresh_token')).thenReturn('refresh_token');
      
      // Mock refresh token failure
      when(mockApiService.refreshToken(any))
          .thenThrow(Exception('Refresh token expired'));
      
      // Act
      final result = await authRepository.isSignedIn();
      
      // Assert
      expect(result, isFalse);
      
      // Verify sign out was called due to refresh failure
      verify(mockPrefs.remove(any)).called(4);
    });

    test('sendPasswordResetEmail should call API service', () async {
      // Arrange
      when(mockApiService.sendPasswordResetEmail(testEmail))
          .thenAnswer((_) async => {});
      
      // Act
      await authRepository.sendPasswordResetEmail(testEmail);
      
      // Assert
      verify(mockApiService.sendPasswordResetEmail(testEmail)).called(1);
    });

    test('getIdToken should refresh token if expired', () async {
      // Arrange
      // Set up expired token
      when(mockPrefs.getString('id_token')).thenReturn('expired_token');
      when(mockPrefs.getString('expiry_time'))
          .thenReturn(DateTime.now().subtract(const Duration(hours: 1)).toIso8601String());
      when(mockPrefs.getString('refresh_token')).thenReturn('refresh_token');
      
      // Set up successful token refresh
      when(mockApiService.refreshToken('refresh_token'))
          .thenAnswer((_) async => {
                'id_token': 'new_token',
                'refresh_token': 'new_refresh_token',
                'expires_in': '3600',
              });
      
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      
      // Act
      final result = await authRepository.getIdToken();
      
      // Assert
      expect(result, 'new_token');
      verify(mockApiService.refreshToken('refresh_token')).called(1);
      verify(mockPrefs.setString('id_token', 'new_token')).called(1);
    });
  });
}
