part of 'discovery_bloc.dart';

/// Base class for discovery events
abstract class DiscoveryEvent extends Equatable {
  /// Constructor
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start the discovery process
class StartDiscovery extends DiscoveryEvent {
  /// Radius in meters to search for profiles
  final double radiusInMeters;
  
  /// Maximum number of profiles to return
  final int limit;
  
  /// Additional filters to apply
  final Map<String, dynamic>? filters;

  /// Constructor
  const StartDiscovery({
    this.radiusInMeters = 5000, // Default 5km
    this.limit = 20,
    this.filters,
  });

  @override
  List<Object?> get props => [radiusInMeters, limit, filters];
}

/// Event to refresh the discovery results
class RefreshDiscovery extends DiscoveryEvent {
  /// Position to search from (optional, will use current position if not provided)
  final Position? position;
  
  /// Radius in meters to search for profiles (optional)
  final double? radius;
  
  /// Maximum number of profiles to return
  final int limit;
  
  /// Additional filters to apply
  final Map<String, dynamic>? filters;

  /// Constructor
  const RefreshDiscovery({
    this.position,
    this.radius,
    this.limit = 20,
    this.filters,
  });

  @override
  List<Object?> get props => [position, radius, limit, filters];
}

/// Event to search for profiles by query
class SearchProfiles extends DiscoveryEvent {
  /// Search query
  final String query;
  
  /// Maximum number of profiles to return
  final int limit;
  
  /// Additional filters to apply
  final Map<String, dynamic>? filters;

  /// Constructor
  const SearchProfiles({
    required this.query,
    this.limit = 20,
    this.filters,
  });

  @override
  List<Object?> get props => [query, limit, filters];
}

/// Event to filter profiles by interests
class FilterByInterests extends DiscoveryEvent {
  /// List of interests to filter by
  final List<String> interests;
  
  /// Maximum number of profiles to return
  final int limit;
  
  /// Additional filters to apply
  final Map<String, dynamic>? filters;
  
  /// Radius in meters to search for profiles
  final double? radiusInMeters;

  /// Constructor
  const FilterByInterests({
    required this.interests,
    this.limit = 20,
    this.filters,
    this.radiusInMeters,
  });

  @override
  List<Object?> get props => [interests, limit, filters, radiusInMeters];
}

/// Event to update the current location
class UpdateLocation extends DiscoveryEvent {
  /// The new position
  final Position position;
  
  /// The user ID to update location for (if authenticated)
  final String? userId;

  /// Constructor
  const UpdateLocation({
    required this.position,
    this.userId,
  });

  @override
  List<Object?> get props => [position, userId];
}

/// Event to set the discovery radius
class SetDiscoveryRadius extends DiscoveryEvent {
  /// Radius in meters to search for profiles
  final double radiusInMeters;

  /// Constructor
  const SetDiscoveryRadius(this.radiusInMeters);

  @override
  List<Object> get props => [radiusInMeters];
}
