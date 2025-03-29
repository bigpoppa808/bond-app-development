import 'package:geolocator/geolocator.dart';

/// Interface for location services
abstract class LocationService {
  /// Initialize the location service and request permissions if needed
  Future<bool> initialize();
  
  /// Get the current position
  Future<Position> getCurrentPosition();
  
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled();
  
  /// Check if location permissions are granted
  Future<LocationPermission> checkPermission();
  
  /// Request location permission
  Future<LocationPermission> requestPermission();
  
  /// Start listening to location updates
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    Duration? interval,
  });
  
  /// Calculate distance between two positions in meters
  double calculateDistance(double startLatitude, double startLongitude, 
                          double endLatitude, double endLongitude);
  
  /// Check if the user is within a certain radius of a location
  bool isWithinRadius(Position userPosition, double targetLatitude, 
                     double targetLongitude, double radiusInMeters);
}

/// Implementation of the LocationService using Geolocator package
class GeolocatorService implements LocationService {
  /// Initialize the location service and request permissions if needed
  @override
  Future<bool> initialize() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    final permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      final requestedPermission = await requestPermission();
      return requestedPermission != LocationPermission.denied && 
             requestedPermission != LocationPermission.deniedForever;
    }
    
    return permission != LocationPermission.deniedForever;
  }
  
  /// Get the current position
  @override
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
  
  /// Check if location services are enabled
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  /// Check if location permissions are granted
  @override
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }
  
  /// Request location permission
  @override
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }
  
  /// Start listening to location updates
  @override
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    Duration? interval,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        timeLimit: interval,
      ),
    );
  }
  
  /// Calculate distance between two positions in meters
  @override
  double calculateDistance(double startLatitude, double startLongitude, 
                          double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
      startLatitude, 
      startLongitude, 
      endLatitude, 
      endLongitude,
    );
  }
  
  /// Check if the user is within a certain radius of a location
  @override
  bool isWithinRadius(Position userPosition, double targetLatitude, 
                     double targetLongitude, double radiusInMeters) {
    final distance = calculateDistance(
      userPosition.latitude, 
      userPosition.longitude, 
      targetLatitude, 
      targetLongitude,
    );
    
    return distance <= radiusInMeters;
  }
}
