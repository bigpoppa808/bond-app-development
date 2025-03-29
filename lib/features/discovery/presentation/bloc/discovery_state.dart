part of 'discovery_bloc.dart';

/// Base class for discovery states
abstract class DiscoveryState extends Equatable {
  /// Constructor
  const DiscoveryState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class DiscoveryInitial extends DiscoveryState {}

/// Loading state
class DiscoveryLoading extends DiscoveryState {}

/// Searching state
class DiscoverySearching extends DiscoveryState {}

/// Error state
class DiscoveryError extends DiscoveryState {
  /// Error message
  final String message;

  /// Constructor
  const DiscoveryError(this.message);

  @override
  List<Object> get props => [message];
}

/// State when profiles are loaded
class DiscoveryLoaded extends DiscoveryState {
  /// List of profiles
  final List<ProfileModel> profiles;
  
  /// Current position
  final Position currentPosition;
  
  /// Radius in meters
  final double radiusInMeters;
  
  /// Interests filter if applied
  final List<String>? filteredByInterests;

  /// Constructor
  const DiscoveryLoaded({
    required this.profiles,
    required this.currentPosition,
    required this.radiusInMeters,
    this.filteredByInterests,
  });

  @override
  List<Object?> get props => [
    profiles, 
    currentPosition, 
    radiusInMeters, 
    filteredByInterests
  ];
  
  /// Create a copy with updated values
  DiscoveryLoaded copyWith({
    List<ProfileModel>? profiles,
    Position? currentPosition,
    double? radiusInMeters,
    List<String>? filteredByInterests,
  }) {
    return DiscoveryLoaded(
      profiles: profiles ?? this.profiles,
      currentPosition: currentPosition ?? this.currentPosition,
      radiusInMeters: radiusInMeters ?? this.radiusInMeters,
      filteredByInterests: filteredByInterests ?? this.filteredByInterests,
    );
  }
}

/// State when search results are loaded
class DiscoverySearchResults extends DiscoveryState {
  /// Search query
  final String query;
  
  /// List of profiles
  final List<ProfileModel> profiles;

  /// Constructor
  const DiscoverySearchResults({
    required this.query,
    required this.profiles,
  });

  @override
  List<Object> get props => [query, profiles];
}

/// State when interest filter results are loaded
class DiscoveryInterestResults extends DiscoveryState {
  /// List of interests
  final List<String> interests;
  
  /// List of profiles
  final List<ProfileModel> profiles;

  /// Constructor
  const DiscoveryInterestResults({
    required this.interests,
    required this.profiles,
  });

  @override
  List<Object> get props => [interests, profiles];
}
