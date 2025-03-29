import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bond_app/core/managers/location_manager.dart';
import 'package:bond_app/features/discovery/data/repositories/discovery_repository.dart';
import 'package:bond_app/features/profile/domain/models/profile_model.dart';
import 'package:bond_app/core/services/profile_indexing_service.dart';
import 'package:get_it/get_it.dart';

part 'discovery_event.dart';
part 'discovery_state.dart';

/// BLoC for handling discovery-related logic
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final DiscoveryRepository _discoveryRepository;
  final LocationManager _locationManager;
  final ProfileIndexingService _profileIndexingService;
  
  StreamSubscription? _locationSubscription;
  
  /// Constructor
  DiscoveryBloc({
    required DiscoveryRepository discoveryRepository,
    required LocationManager locationManager,
    ProfileIndexingService? profileIndexingService,
  }) : _discoveryRepository = discoveryRepository,
       _locationManager = locationManager,
       _profileIndexingService = profileIndexingService ?? GetIt.I<ProfileIndexingService>(),
       super(DiscoveryInitial()) {
    on<StartDiscovery>(_onStartDiscovery);
    on<RefreshDiscovery>(_onRefreshDiscovery);
    on<SearchProfiles>(_onSearchProfiles);
    on<FilterByInterests>(_onFilterByInterests);
    on<UpdateLocation>(_onUpdateLocation);
    on<SetDiscoveryRadius>(_onSetDiscoveryRadius);
  }
  
  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
  
  /// Handle StartDiscovery event
  Future<void> _onStartDiscovery(
    StartDiscovery event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(DiscoveryLoading());
    
    try {
      // Initialize location tracking
      final initialized = await _locationManager.initialize();
      if (!initialized) {
        emit(const DiscoveryError('Location services are not available'));
        return;
      }
      
      // Start location tracking
      await _locationManager.startTracking();
      
      // Subscribe to location updates
      _locationSubscription?.cancel();
      _locationSubscription = _locationManager.positionStream.listen((position) {
        add(UpdateLocation(position));
      });
      
      // Get current position
      final position = await _locationManager.getCurrentPosition();
      if (position == null) {
        emit(const DiscoveryError('Could not get current location'));
        return;
      }
      
      // Find nearby profiles
      final profiles = await _discoveryRepository.findProfilesNearLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusInMeters: event.radiusInMeters,
        limit: event.limit,
        filters: event.filters,
      );
      
      emit(DiscoveryLoaded(
        profiles: profiles,
        currentPosition: position,
        radiusInMeters: event.radiusInMeters,
      ));
    } catch (e) {
      emit(DiscoveryError(e.toString()));
    }
  }
  
  /// Handle RefreshDiscovery event
  Future<void> _onRefreshDiscovery(
    RefreshDiscovery event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state is DiscoveryLoaded) {
      final currentState = state as DiscoveryLoaded;
      emit(DiscoveryLoading());
      
      try {
        // Use provided position or get current position
        final position = event.position ?? 
                         await _locationManager.getCurrentPosition() ?? 
                         currentState.currentPosition;
        
        // Use provided radius or current radius
        final radius = event.radius ?? currentState.radiusInMeters;
        
        // Find nearby profiles
        final profiles = await _discoveryRepository.findProfilesNearLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          radiusInMeters: radius,
          limit: event.limit,
          filters: event.filters ?? (currentState.filteredByInterests != null ? 
                  {'hobbies': currentState.filteredByInterests} : null),
        );
        
        emit(DiscoveryLoaded(
          profiles: profiles,
          currentPosition: position,
          radiusInMeters: radius,
          filteredByInterests: currentState.filteredByInterests,
        ));
      } catch (e) {
        emit(DiscoveryError(e.toString()));
      }
    }
  }
  
  /// Handle SearchProfiles event
  Future<void> _onSearchProfiles(
    SearchProfiles event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(DiscoverySearching());
    
    try {
      final profiles = await _discoveryRepository.searchProfiles(
        query: event.query,
        limit: event.limit,
        filters: event.filters,
      );
      
      emit(DiscoverySearchResults(
        query: event.query,
        profiles: profiles,
      ));
    } catch (e) {
      emit(DiscoveryError(e.toString()));
    }
  }
  
  /// Handle FilterByInterests event
  Future<void> _onFilterByInterests(
    FilterByInterests event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(DiscoveryLoading());
    
    try {
      final profiles = await _discoveryRepository.findProfilesByInterests(
        interests: event.interests,
        limit: event.limit,
        filters: event.filters,
      );
      
      // Get current position if available
      Position? position;
      if (state is DiscoveryLoaded) {
        position = (state as DiscoveryLoaded).currentPosition;
      } else {
        position = await _locationManager.getCurrentPosition();
      }
      
      if (position != null) {
        emit(DiscoveryLoaded(
          profiles: profiles,
          currentPosition: position,
          radiusInMeters: event.radiusInMeters ?? 5000, // Default 5km
          filteredByInterests: event.interests,
        ));
      } else {
        emit(DiscoveryInterestResults(
          interests: event.interests,
          profiles: profiles,
        ));
      }
    } catch (e) {
      emit(DiscoveryError(e.toString()));
    }
  }
  
  /// Handle UpdateLocation event
  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<DiscoveryState> emit,
  ) async {
    try {
      if (state is DiscoveryLoaded) {
        final currentState = state as DiscoveryLoaded;
        
        // Update the current location in the state
        emit(DiscoveryLoaded(
          profiles: currentState.profiles,
          currentPosition: event.position,
          radiusInMeters: currentState.radiusInMeters,
          filteredByInterests: currentState.filteredByInterests,
        ));
        
        // If the user is authenticated, update their location in Algolia
        if (event.userId != null) {
          await _profileIndexingService.updateProfileLocation(
            event.userId!,
            event.position,
          );
        }
        
        // Refresh the discovery results with the new location
        add(RefreshDiscovery(position: event.position, radius: currentState.radiusInMeters));
      }
    } catch (e) {
      emit(DiscoveryError('Failed to update location: $e'));
    }
  }
  
  /// Handle SetDiscoveryRadius event
  void _onSetDiscoveryRadius(
    SetDiscoveryRadius event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state is DiscoveryLoaded) {
      final currentState = state as DiscoveryLoaded;
      emit(DiscoveryLoading());
      
      try {
        // Find nearby profiles with the new radius
        final profiles = await _discoveryRepository.findProfilesNearLocation(
          latitude: currentState.currentPosition.latitude,
          longitude: currentState.currentPosition.longitude,
          radiusInMeters: event.radiusInMeters,
          limit: 20, // Default limit
          filters: currentState.filteredByInterests != null ? 
                  {'hobbies': currentState.filteredByInterests} : null,
        );
        
        emit(DiscoveryLoaded(
          profiles: profiles,
          currentPosition: currentState.currentPosition,
          radiusInMeters: event.radiusInMeters,
          filteredByInterests: currentState.filteredByInterests,
        ));
      } catch (e) {
        emit(DiscoveryError(e.toString()));
      }
    }
  }
}
