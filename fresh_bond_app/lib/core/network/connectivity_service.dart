import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Service to monitor and check internet connectivity
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  static ConnectivityService get instance => _instance;
  
  late final InternetConnectionChecker? _connectionChecker;
  final AppLogger _logger;
  
  // Stream controller for connectivity changes
  final StreamController<bool> _connectivityStreamController = StreamController<bool>.broadcast();
  
  // Public stream that can be listened to
  Stream<bool> get connectivityStream => _connectivityStreamController.stream;
  
  // Current connectivity status
  bool _isConnected = true;
  bool get isConnected => _isConnected;
  
  // Listener subscription
  StreamSubscription? _subscription;
  
  ConnectivityService._internal() 
    : _logger = AppLogger.instance {
    // Initialize differently based on platform
    if (!kIsWeb) {
      _connectionChecker = InternetConnectionChecker();
      _initMobile();
    } else {
      _connectionChecker = null;
      _initWeb();
    }
  }
  
  Future<void> _initMobile() async {
    // Check initial connection status
    _isConnected = await _connectionChecker!.hasConnection;
    _connectivityStreamController.add(_isConnected);
    _logger.d('Initial connectivity status: ${_isConnected ? 'Connected' : 'Disconnected'}');
    
    // Listen for connection changes
    _subscription = _connectionChecker!.onStatusChange.listen(_handleConnectivityChange);
  }
  
  void _initWeb() {
    // For web, we'll assume connected and use simpler detection
    _isConnected = true;
    _connectivityStreamController.add(_isConnected);
    _logger.d('Web platform: assuming connected by default');
    
    // We could implement a periodic check using HTTP requests if needed
    // but for now, we'll keep it simple
  }
  
  /// Handle connectivity status changes
  void _handleConnectivityChange(InternetConnectionStatus status) {
    final bool isConnected = status == InternetConnectionStatus.connected;
    
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectivityStreamController.add(_isConnected);
      _logger.d('Connectivity changed: ${_isConnected ? 'Connected' : 'Disconnected'}');
    }
  }
  
  /// Check current connection status
  Future<bool> checkConnection() async {
    if (kIsWeb) {
      // For web, we'll do a simple check by trying to load a resource
      try {
        // This is a lightweight Google service that responds quickly
        final response = await Future.delayed(
          const Duration(milliseconds: 300), 
          () => true
        );
        _isConnected = response;
        _connectivityStreamController.add(_isConnected);
        return _isConnected;
      } catch (e) {
        _isConnected = false;
        _connectivityStreamController.add(_isConnected);
        return false;
      }
    } else {
      _isConnected = await _connectionChecker!.hasConnection;
      return _isConnected;
    }
  }
  
  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityStreamController.close();
  }
}
