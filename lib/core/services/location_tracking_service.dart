import 'dart:async';
import 'package:bond_app/core/managers/location_manager.dart';
import 'package:bond_app/core/services/profile_indexing_service.dart';
import 'package:bond_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:bond_app/features/profile/domain/models/profile_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';

/// Service responsible for tracking user location and updating it in the Algolia index
class LocationTrackingService {
  final LocationManager _locationManager;
  final ProfileIndexingService _profileIndexingService;
  final ProfileRepository _profileRepository;
  
  Timer? _locationUpdateTimer;
  StreamSubscription<Position>? _positionStreamSubscription;
  
  String? _currentUserId;
  bool _isTracking = false;
  
  /// Default update interval in minutes
  static const int defaultUpdateIntervalMinutes = 15;
  
  /// Constructor
  LocationTrackingService({
    LocationManager? locationManager,
    ProfileIndexingService? profileIndexingService,
    ProfileRepository? profileRepository,
  }) : _locationManager = locationManager ?? GetIt.I<LocationManager>(),
       _profileIndexingService = profileIndexingService ?? GetIt.I<ProfileIndexingService>(),
       _profileRepository = profileRepository ?? GetIt.I<ProfileRepository>();
  
  /// Start tracking user location
  Future<void> startTracking(String userId, {int updateIntervalMinutes = defaultUpdateIntervalMinutes}) async {
    if (_isTracking) {
      await stopTracking();
    }
    
    _currentUserId = userId;
    
    try {
      // Get the user's profile to check if they have location tracking enabled
      final profile = await _profileRepository.getProfile(userId);
      
      if (profile == null) {
        debugPrint('Cannot start location tracking: Profile not found');
        return;
      }
      
      // Check if location tracking is enabled in the user's profile
      if (!profile.isLocationTrackingEnabled) {
        debugPrint('Location tracking is disabled in user preferences');
        return;
      }
      
      // Check if location services are enabled
      final isLocationServiceEnabled = await _locationManager.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        debugPrint('Location services are not enabled');
        return;
      }
      
      // Check if we have permission to access location
      final permission = await _locationManager.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied');
        return;
      }
      
      _isTracking = true;
      
      // Get current position and update it
      final position = await _locationManager.getCurrentPosition();
      if (position != null) {
        await _updateUserLocation(position);
      }
      
      // Set up periodic updates
      _locationUpdateTimer = Timer.periodic(
        Duration(minutes: updateIntervalMinutes),
        (_) async {
          final currentPosition = await _locationManager.getCurrentPosition();
          if (currentPosition != null) {
            await _updateUserLocation(currentPosition);
          }
        },
      );
      
      // Set up position stream for more accurate tracking when the app is in foreground
      _positionStreamSubscription = _locationManager.getPositionStream().listen(
        (position) async {
          await _updateUserLocation(position);
        },
        onError: (error) {
          debugPrint('Position stream error: $error');
        },
      );
      
      debugPrint('Location tracking started for user: $userId');
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
    }
  }
  
  /// Stop tracking user location
  Future<void> stopTracking() async {
    _isTracking = false;
    _currentUserId = null;
    
    // Cancel timer
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    
    // Cancel position stream
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    
    debugPrint('Location tracking stopped');
  }
  
  /// Check if tracking is currently active
  bool get isTracking => _isTracking;
  
  /// Get the ID of the user being tracked
  String? get currentUserId => _currentUserId;
  
  /// Update user location in profile and Algolia index
  Future<void> _updateUserLocation(Position position) async {
    if (!_isTracking || _currentUserId == null) return;
    
    try {
      // Get the latest profile to ensure we have the most up-to-date preferences
      final profile = await _profileRepository.getProfile(_currentUserId!);
      
      if (profile == null) {
        debugPrint('Cannot update location: Profile not found');
        return;
      }
      
      // Check if location tracking is still enabled
      if (!profile.isLocationTrackingEnabled) {
        debugPrint('Location tracking is now disabled in user preferences');
        await stopTracking();
        return;
      }
      
      // Update the profile with the new location
      final updatedProfile = profile.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        lastLocationUpdate: DateTime.now(),
      );
      
      // Save the updated profile
      await _profileRepository.updateProfile(updatedProfile);
      
      // Only update the location in Algolia if the user's privacy settings allow it
      if (profile.privacySettings.showLocation && profile.privacySettings.discoverable) {
        await _profileIndexingService.updateProfileLocation(
          _currentUserId!,
          position,
        );
        debugPrint('Location updated for user: $_currentUserId');
      } else {
        debugPrint('Location not indexed due to privacy settings');
      }
    } catch (e) {
      debugPrint('Error updating user location: $e');
    }
  }
  
  /// Force an immediate location update
  Future<void> forceLocationUpdate() async {
    if (!_isTracking || _currentUserId == null) return;
    
    try {
      final position = await _locationManager.getCurrentPosition();
      if (position != null) {
        await _updateUserLocation(position);
      }
    } catch (e) {
      debugPrint('Error forcing location update: $e');
    }
  }
}
