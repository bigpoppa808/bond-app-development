import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fresh_bond_app/core/config/app_config.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';

/// A centralized error handling class that can be used across the app
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  static ErrorHandler get instance => _instance;
  
  late final AppLogger _logger;
  
  ErrorHandler._internal() {
    _logger = AppLogger.instance;
  }
  
  // Function that can be used as a zone error handler
  static Future<void> handleZoneError(Object error, StackTrace stackTrace) async {
    final handler = ErrorHandler.instance;
    handler.logError(error, stackTrace: stackTrace);
    
    // In production, we could send the error to a reporting service
    if (AppConfig.instance().shouldReportErrors) {
      handler.reportError(error, stackTrace: stackTrace);
    }
  }
  
  // Handle and categorize different types of errors
  String handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is SocketException) {
      return 'Network error: Please check your internet connection';
    } else if (error is TimeoutException) {
      return 'Request timeout: Please try again';
    } else if (error is FormatException) {
      return 'Data format error: Please try again later';
    } else {
      return error?.toString() ?? 'An unknown error occurred';
    }
  }
  
  // Log errors to console in development
  void logError(dynamic error, {StackTrace? stackTrace}) {
    _logger.e('Error occurred', error: error, stackTrace: stackTrace);
  }
  
  // Report errors to a service in production
  Future<void> reportError(dynamic error, {StackTrace? stackTrace}) async {
    // Here we would implement crash reporting service integration
    // For example, Firebase Crashlytics or Sentry
    _logger.i('Reporting error to service', error: error, stackTrace: stackTrace);
    
    // Example implementation:
    // await FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
  
  // Handle Dio specific errors
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout: Please try again';
      case DioExceptionType.sendTimeout:
        return 'Send timeout: Please try again';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout: Please try again';
      case DioExceptionType.badCertificate:
        return 'Bad certificate: Please contact support';
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error: Please check your internet connection';
      case DioExceptionType.unknown:
        return 'An unknown error occurred';
    }
  }
  
  // Handle HTTP error responses
  String _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    
    if (statusCode == 401) {
      return 'Authentication failed: Please sign in again';
    } else if (statusCode == 403) {
      return 'You don\'t have permission to access this resource';
    } else if (statusCode == 404) {
      return 'Resource not found';
    } else if (statusCode == 500) {
      return 'Server error: Please try again later';
    } else if (data is Map && data['error'] is Map && data['error']['message'] != null) {
      // Handle Firebase REST API error format
      return data['error']['message'];
    }
    
    return 'Error ${statusCode ?? 'unknown'}: ${data?.toString() ?? 'No details available'}';
  }
}
