import 'package:bloc/bloc.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:bond_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:bond_app/core/services/profile_indexing_service.dart';
import 'package:bond_app/core/managers/location_manager.dart';
import 'package:get_it/get_it.dart';

/// BLoC for managing profile state and events
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final ProfileIndexingService _profileIndexingService;
  final LocationManager _locationManager;

  ProfileBloc({
    required ProfileRepository profileRepository,
    ProfileIndexingService? profileIndexingService,
    LocationManager? locationManager,
  }) : _profileRepository = profileRepository,
       _profileIndexingService = profileIndexingService ?? GetIt.I<ProfileIndexingService>(),
       _locationManager = locationManager ?? GetIt.I<LocationManager>(),
       super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<CreateProfile>(_onCreateProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<DeleteProfile>(_onDeleteProfile);
    on<UploadProfilePhoto>(_onUploadProfilePhoto);
    on<DeleteProfilePhoto>(_onDeleteProfilePhoto);
    on<LoadProfilesByInterests>(_onLoadProfilesByInterests);
    on<UpdateProfileLocation>(_onUpdateProfileLocation);
  }

  /// Handle LoadProfile event
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      
      final profile = await _profileRepository.getProfile(event.userId);
      
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(const ProfileError('Profile not found'));
      }
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  /// Handle CreateProfile event
  Future<void> _onCreateProfile(
    CreateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileCreating());
      
      final createdProfile = await _profileRepository.createProfile(event.profile);
      
      // Index the profile in Algolia with current location if available
      final position = await _locationManager.getCurrentPosition();
      if (position != null) {
        await _profileIndexingService.indexProfile(createdProfile, position: position);
      } else {
        await _profileIndexingService.indexProfile(createdProfile);
      }
      
      emit(ProfileCreated(createdProfile));
      emit(ProfileLoaded(createdProfile));
    } catch (e) {
      emit(ProfileError('Failed to create profile: $e'));
    }
  }

  /// Handle UpdateProfile event
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileUpdating());
      
      final updatedProfile = await _profileRepository.updateProfile(event.profile);
      
      // Update the profile in Algolia with current location if available
      final position = await _locationManager.getCurrentPosition();
      if (position != null) {
        await _profileIndexingService.indexProfile(updatedProfile, position: position);
      } else {
        await _profileIndexingService.indexProfile(updatedProfile);
      }
      
      emit(ProfileUpdated(updatedProfile));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e'));
    }
  }

  /// Handle DeleteProfile event
  Future<void> _onDeleteProfile(
    DeleteProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileDeleting());
      
      await _profileRepository.deleteProfile(event.userId);
      
      // Remove the profile from Algolia index
      await _profileIndexingService.removeProfile(event.userId);
      
      emit(ProfileDeleted(event.userId));
      emit(ProfileInitial());
    } catch (e) {
      emit(ProfileError('Failed to delete profile: $e'));
    }
  }

  /// Handle UploadProfilePhoto event
  Future<void> _onUploadProfilePhoto(
    UploadProfilePhoto event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfilePhotoUploading());
      
      final photoUrl = await _profileRepository.uploadProfilePhoto(
        event.userId,
        event.filePath,
      );
      
      emit(ProfilePhotoUploaded(photoUrl));
      
      // Reload the profile to get the updated photos
      add(LoadProfile(event.userId));
    } catch (e) {
      emit(ProfileError('Failed to upload profile photo: $e'));
    }
  }

  /// Handle DeleteProfilePhoto event
  Future<void> _onDeleteProfilePhoto(
    DeleteProfilePhoto event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfilePhotoDeleting());
      
      await _profileRepository.deleteProfilePhoto(
        event.userId,
        event.photoUrl,
      );
      
      emit(ProfilePhotoDeleted(event.photoUrl));
      
      // Reload the profile to get the updated photos
      add(LoadProfile(event.userId));
    } catch (e) {
      emit(ProfileError('Failed to delete profile photo: $e'));
    }
  }

  /// Handle LoadProfilesByInterests event
  Future<void> _onLoadProfilesByInterests(
    LoadProfilesByInterests event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      
      final profiles = await _profileRepository.getProfilesByInterests(
        event.interests,
        limit: event.limit,
      );
      
      emit(ProfilesLoaded(profiles));
    } catch (e) {
      emit(ProfileError('Failed to load profiles by interests: $e'));
    }
  }

  /// Handle UpdateProfileLocation event
  Future<void> _onUpdateProfileLocation(
    UpdateProfileLocation event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is ProfileLoaded) {
        final currentProfile = (state as ProfileLoaded).profile;
        
        // Update profile with new location
        final updatedProfile = currentProfile.copyWith(
          latitude: event.position.latitude,
          longitude: event.position.longitude,
          lastLocationUpdate: DateTime.now(),
        );
        
        // Save to repository
        await _profileRepository.updateProfile(updatedProfile);
        
        // Update in Algolia if privacy settings allow
        if (updatedProfile.privacySettings.showLocation && 
            updatedProfile.privacySettings.discoverable) {
          await _profileIndexingService.updateProfileLocation(
            updatedProfile.userId,
            event.position,
          );
        }
        
        emit(ProfileLocationUpdated(updatedProfile));
        emit(ProfileLoaded(updatedProfile));
      }
    } catch (e) {
      emit(ProfileError('Failed to update location: $e'));
    }
  }
}
