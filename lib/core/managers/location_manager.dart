import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bond_app/core/services/location_service.dart';

/// Class responsible for managing location tracking and caching
class LocationManager {
  final LocationService _locationService;
  final String _lastLocationLatKey = 'last_location_lat';
  final String _lastLocationLngKey = 'last_location_lng';
  final String _lastLocationTimeKey = 'last_location_time';
  
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastKnownPosition;
  final _positionController = StreamController<Position>.broadcast();
  
  /// Stream of position updates
  Stream<Position> get positionStream => _positionController.stream;
  
  /// Last known position
  Position? get lastKnownPosition => _lastKnownPosition;
  
  /// Constructor
  LocationManager(this._locationService);
  
  /// Initialize location tracking
  Future<bool> initialize() async {
    final initialized = await _locationService.initialize();
    if (initialized) {
      await _loadLastKnownLocation();
      return true;
    }
    return false;
  }
  
  /// Start tracking location
  Future<void> startTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    Duration interval = const Duration(minutes: 1),
  }) async {
    // Stop any existing tracking
    await stopTracking();
    
    // Start new tracking
    _positionStreamSubscription = _locationService.getPositionStream(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      interval: interval,
    ).listen(_handlePositionUpdate);
    
    // Get current position immediately
    try {
      final position = await _locationService.getCurrentPosition();
      _handlePositionUpdate(position);
    } catch (e) {
      debugPrint('Error getting current position: $e');
    }
  }
  
  /// Stop tracking location
  Future<void> stopTracking() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }
  
  /// Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final position = await _locationService.getCurrentPosition();
      _handlePositionUpdate(position);
      return position;
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return _lastKnownPosition;
    }
  }
  
  /// Handle position update
  void _handlePositionUpdate(Position position) {
    _lastKnownPosition = position;
    _positionController.add(position);
    _saveLastKnownLocation(position);
  }
  
  /// Save last known location to shared preferences
  Future<void> _saveLastKnownLocation(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lastLocationLatKey, position.latitude);
    await prefs.setDouble(_lastLocationLngKey, position.longitude);
    await prefs.setInt(_lastLocationTimeKey, position.timestamp?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch);
  }
  
  /// Load last known location from shared preferences
  Future<void> _loadLastKnownLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_lastLocationLatKey);
    final lng = prefs.getDouble(_lastLocationLngKey);
    final time = prefs.getInt(_lastLocationTimeKey);
    
    if (lat != null && lng != null && time != null) {
      _lastKnownPosition = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.fromMillisecondsSinceEpoch(time),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }
  
  /// Check if user is within radius of a location
  bool isWithinRadius(double targetLatitude, double targetLongitude, double radiusInMeters) {
    if (_lastKnownPosition == null) return false;
    
    return _locationService.isWithinRadius(
      _lastKnownPosition!, 
      targetLatitude, 
      targetLongitude, 
      radiusInMeters,
    );
  }
  
  /// Calculate distance to a location in meters
  double distanceTo(double targetLatitude, double targetLongitude) {
    if (_lastKnownPosition == null) return double.infinity;
    
    return _locationService.calculateDistance(
      _lastKnownPosition!.latitude,
      _lastKnownPosition!.longitude,
      targetLatitude,
      targetLongitude,
    );
  }
  
  /// Dispose resources
  void dispose() {
    stopTracking();
    _positionController.close();
  }
}
