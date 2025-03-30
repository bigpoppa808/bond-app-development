import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/core/utils/error_handler.dart';
import 'package:fresh_bond_app/features/auth/domain/models/user_model.dart';

/// Service for handling Firebase Authentication and Firestore operations via REST API
/// This avoids direct Firebase SDK dependencies that might cause iOS build issues
class FirebaseApiService {
  final String baseUrl;
  final String apiKey;
  final Dio _dio;
  final AppLogger _logger;
  final ErrorHandler _errorHandler;

  FirebaseApiService({
    required this.baseUrl,
    required this.apiKey,
  }) : _dio = Dio(),
       _logger = AppLogger.instance,
       _errorHandler = ErrorHandler.instance {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: 5000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 3000);
    _dio.options.contentType = Headers.jsonContentType;
    _dio.options.responseType = ResponseType.json;
    
    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => _logger.d(object.toString()),
    ));
  }

  // Authentication APIs
  
  /// Sign in with email and password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        '/v1/accounts:signInWithPassword',
        queryParameters: {'key': apiKey},
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      );
      
      _logger.i('User signed in successfully: ${email}');
      return response.data;
    } catch (e) {
      final errorMessage = _errorHandler.handleError(e);
      _logger.e('Sign in failed', error: e);
      throw errorMessage;
    }
  }

  /// Sign up with email and password
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      final response = await _dio.post(
        '/v1/accounts:signUp',
        queryParameters: {'key': apiKey},
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      );
      
      _logger.i('User signed up successfully: ${email}');
      return response.data;
    } catch (e) {
      final errorMessage = _errorHandler.handleError(e);
      _logger.e('Sign up failed', error: e);
      throw errorMessage;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _dio.post(
        '/v1/accounts:sendOobCode',
        queryParameters: {'key': apiKey},
        data: {
          'requestType': 'PASSWORD_RESET',
          'email': email,
        },
      );
      
      _logger.i('Password reset email sent to: ${email}');
    } catch (e) {
      final errorMessage = _errorHandler.handleError(e);
      _logger.e('Send password reset email failed', error: e);
      throw errorMessage;
    }
  }

  /// Refresh authentication token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        'https://securetoken.googleapis.com/v1/token',
        queryParameters: {'key': apiKey},
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );
      
      _logger.i('Token refreshed successfully');
      return response.data;
    } catch (e) {
      final errorMessage = _errorHandler.handleError(e);
      _logger.e('Token refresh failed', error: e);
      throw errorMessage;
    }
  }

  // Firestore APIs
  
  /// Get user profile data
  Future<Map<String, dynamic>> getUserProfile(String uid, String idToken) async {
    try {
      final response = await _dio.get(
        'https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents/users/${uid}',
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );
      
      _logger.i('User profile fetched successfully for UID: ${uid}');
      return _convertFirestoreResponse(response.data);
    } catch (e) {
      final errorMessage = _errorHandler.handleError(e);
      _logger.e('Get user profile failed', error: e);
      throw errorMessage;
    }
  }

  /// Update user profile data
  Future<Map<String, dynamic>> updateUserProfile(
    String uid,
    String idToken,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final data = _convertToFirestoreData(profileData);
      final response = await _dio.patch(
        'https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents/users/${uid}',
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
        data: {
          'fields': data,
        },
      );
      
      _logger.i('User profile updated successfully for UID: ${uid}');
      return _convertFirestoreResponse(response.data);
    } catch (e) {
      final errorMessage = _errorHandler.handleError(e);
      _logger.e('Update user profile failed', error: e);
      throw errorMessage;
    }
  }

  // Helper methods to convert between Firestore format and regular JSON
  
  Map<String, dynamic> _convertFirestoreResponse(Map<String, dynamic> response) {
    final Map<String, dynamic> result = {};
    final fields = response['fields'] as Map<String, dynamic>?;
    
    if (fields != null) {
      fields.forEach((key, value) {
        result[key] = _extractFirestoreValue(value);
      });
    }
    
    return result;
  }

  dynamic _extractFirestoreValue(Map<String, dynamic> fieldValue) {
    final type = fieldValue.keys.first;
    final value = fieldValue[type];
    
    switch (type) {
      case 'stringValue':
        return value;
      case 'integerValue':
        return int.parse(value.toString());
      case 'doubleValue':
        return double.parse(value.toString());
      case 'booleanValue':
        return value;
      case 'nullValue':
        return null;
      case 'mapValue':
        return _convertFirestoreResponse(value);
      case 'arrayValue':
        return (value['values'] as List?)
            ?.map((v) => _extractFirestoreValue(v))
            .toList();
      default:
        return value.toString();
    }
  }

  Map<String, dynamic> _convertToFirestoreData(Map<String, dynamic> data) {
    final Map<String, dynamic> result = {};
    
    data.forEach((key, value) {
      result[key] = _convertToFirestoreValue(value);
    });
    
    return result;
  }

  Map<String, dynamic> _convertToFirestoreValue(dynamic value) {
    if (value == null) {
      return {'nullValue': null};
    } else if (value is String) {
      return {'stringValue': value};
    } else if (value is int) {
      return {'integerValue': value.toString()};
    } else if (value is double) {
      return {'doubleValue': value};
    } else if (value is bool) {
      return {'booleanValue': value};
    } else if (value is List) {
      return {
        'arrayValue': {
          'values': value.map((v) => _convertToFirestoreValue(v)).toList(),
        },
      };
    } else if (value is Map) {
      return {
        'mapValue': {
          'fields': _convertToFirestoreData(Map<String, dynamic>.from(value)),
        },
      };
    } else {
      return {'stringValue': value.toString()};
    }
  }
}
