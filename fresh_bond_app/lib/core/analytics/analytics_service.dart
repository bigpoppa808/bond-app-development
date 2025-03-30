import 'package:dio/dio.dart';
import 'package:fresh_bond_app/core/config/app_config.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

/// A REST-based analytics service that avoids relying on
/// native Firebase Analytics SDK to prevent iOS build issues
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  
  final Dio _dio;
  final AppLogger _logger;
  late final String _userId;
  late final String _sessionId;
  final bool _enabled;
  
  // Example analytics endpoint - would be replaced with actual service
  final String _analyticsEndpoint = 'https://example.com/analytics';
  
  static AnalyticsService get instance => _instance;
  
  AnalyticsService._internal() 
    : _dio = Dio(),
      _logger = AppLogger.instance,
      _enabled = AppConfig.instance().analyticsEnabled {
    // Generate anonymous user ID for analytics
    _userId = const Uuid().v4();
    _sessionId = const Uuid().v4();
    
    _logger.d('Analytics initialized with session ID: $_sessionId');
  }
  
  /// Logs a screen view event
  Future<void> logScreen(String screenName) async {
    if (!_enabled) return;
    
    try {
      await _sendEvent('screen_view', {
        'screen_name': screenName,
      });
      _logger.d('Logged screen view: $screenName');
    } catch (e) {
      _logger.e('Failed to log screen view', error: e);
    }
  }
  
  /// Logs a user action event
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (!_enabled) return;
    
    try {
      await _sendEvent(eventName, parameters ?? {});
      _logger.d('Logged event: $eventName');
    } catch (e) {
      _logger.e('Failed to log event', error: e);
    }
  }
  
  /// Sets user ID for tracking signed-in users
  Future<void> setUserId(String userId) async {
    if (!_enabled) return;
    
    try {
      await _sendEvent('set_user_id', {
        'user_id': userId,
      });
      _logger.d('Set user ID: $userId');
    } catch (e) {
      _logger.e('Failed to set user ID', error: e);
    }
  }
  
  /// Logs authentication events
  Future<void> logLogin(String method) async {
    if (!_enabled) return;
    
    try {
      await _sendEvent('login', {
        'method': method,
      });
      _logger.d('Logged login event with method: $method');
    } catch (e) {
      _logger.e('Failed to log login event', error: e);
    }
  }
  
  /// Logs sign up events
  Future<void> logSignUp(String method) async {
    if (!_enabled) return;
    
    try {
      await _sendEvent('sign_up', {
        'method': method,
      });
      _logger.d('Logged sign up event with method: $method');
    } catch (e) {
      _logger.e('Failed to log sign up event', error: e);
    }
  }
  
  /// Logs errors for monitoring
  Future<void> logError(String error, {StackTrace? stackTrace}) async {
    if (!_enabled) return;
    
    try {
      await _sendEvent('error', {
        'error_message': error,
        'stack_trace': stackTrace?.toString(),
      });
      _logger.d('Logged error: $error');
    } catch (e) {
      _logger.e('Failed to log error event', error: e);
    }
  }
  
  /// Internal method to send events to the analytics service
  Future<void> _sendEvent(String eventName, Map<String, dynamic> parameters) async {
    if (!_enabled) return;
    
    try {
      final payload = {
        'event_name': eventName,
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': _sessionId,
        'user_id': _userId,
        'app_version': '1.0.0',
        'platform': 'iOS', // or Android, would be determined at runtime
        'parameters': parameters,
      };
      
      // In production, this would send data to a real analytics service
      // For development, we'll just log it
      if (AppConfig.instance().isDevelopment) {
        _logger.d('Analytics event (dev only): $payload');
        return;
      }
      
      // Send to analytics endpoint
      await _dio.post(
        _analyticsEndpoint,
        data: payload,
        options: Options(contentType: Headers.jsonContentType),
      );
    } catch (e) {
      // Log but don't throw - analytics should never crash the app
      _logger.e('Analytics event sending failed', error: e);
    }
  }
}
