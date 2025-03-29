import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bond_app/core/managers/location_manager.dart';

/// A class that represents a geofence region
class GeofenceRegion {
  /// Unique identifier for the geofence
  final String id;
  
  /// Latitude of the center point
  final double latitude;
  
  /// Longitude of the center point
  final double longitude;
  
  /// Radius of the geofence in meters
  final double radius;
  
  /// Optional data associated with this geofence
  final Map<String, dynamic>? data;
  
  /// Constructor
  GeofenceRegion({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.data,
  });
}

/// Enum representing geofence event types
enum GeofenceEventType {
  /// User entered the geofence region
  enter,
  
  /// User exited the geofence region
  exit,
  
  /// User is dwelling inside the geofence region
  dwell
}

/// Class representing a geofence event
class GeofenceEvent {
  /// The geofence region
  final GeofenceRegion region;
  
  /// The type of event
  final GeofenceEventType eventType;
  
  /// The position when the event occurred
  final Position position;
  
  /// Constructor
  GeofenceEvent({
    required this.region,
    required this.eventType,
    required this.position,
  });
}

/// A utility class for managing geofences
class GeofencingUtil {
  final LocationManager _locationManager;
  final Map<String, GeofenceRegion> _regions = {};
  final Map<String, bool> _regionStatus = {};
  
  final _geofenceController = StreamController<GeofenceEvent>.broadcast();
  StreamSubscription? _positionSubscription;
  
  /// Stream of geofence events
  Stream<GeofenceEvent> get geofenceEvents => _geofenceController.stream;
  
  /// Constructor
  GeofencingUtil(this._locationManager);
  
  /// Initialize the geofencing utility
  void initialize() {
    _positionSubscription = _locationManager.positionStream.listen(_checkGeofences);
  }
  
  /// Add a geofence region to monitor
  void addRegion(GeofenceRegion region) {
    _regions[region.id] = region;
    _regionStatus[region.id] = false; // Initially outside the region
  }
  
  /// Remove a geofence region
  void removeRegion(String regionId) {
    _regions.remove(regionId);
    _regionStatus.remove(regionId);
  }
  
  /// Clear all geofence regions
  void clearRegions() {
    _regions.clear();
    _regionStatus.clear();
  }
  
  /// Check if user is inside a specific geofence region
  bool isInsideRegion(String regionId) {
    final region = _regions[regionId];
    if (region == null || _locationManager.lastKnownPosition == null) {
      return false;
    }
    
    return _locationManager.isWithinRadius(
      region.latitude, 
      region.longitude, 
      region.radius,
    );
  }
  
  /// Check all geofences against the current position
  void _checkGeofences(Position position) {
    for (final region in _regions.values) {
      final wasInside = _regionStatus[region.id] ?? false;
      
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        region.latitude,
        region.longitude,
      );
      
      final isInside = distance <= region.radius;
      
      // Update region status
      _regionStatus[region.id] = isInside;
      
      // Trigger appropriate events
      if (isInside && !wasInside) {
        // Entered region
        _geofenceController.add(GeofenceEvent(
          region: region,
          eventType: GeofenceEventType.enter,
          position: position,
        ));
      } else if (!isInside && wasInside) {
        // Exited region
        _geofenceController.add(GeofenceEvent(
          region: region,
          eventType: GeofenceEventType.exit,
          position: position,
        ));
      } else if (isInside && wasInside) {
        // Dwelling in region
        _geofenceController.add(GeofenceEvent(
          region: region,
          eventType: GeofenceEventType.dwell,
          position: position,
        ));
      }
    }
  }
  
  /// Dispose resources
  void dispose() {
    _positionSubscription?.cancel();
    _geofenceController.close();
  }
}
