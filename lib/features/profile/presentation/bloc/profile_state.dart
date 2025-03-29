import 'package:equatable/equatable.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:geolocator/geolocator.dart';

/// Base class for profile states
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no profile has been loaded
class ProfileInitial extends ProfileState {}

/// State when profile is loading
class ProfileLoading extends ProfileState {}

/// State when profile is loaded successfully
class ProfileLoaded extends ProfileState {
  final ProfileModel profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

/// State when multiple profiles are loaded successfully
class ProfilesLoaded extends ProfileState {
  final List<ProfileModel> profiles;

  const ProfilesLoaded(this.profiles);

  @override
  List<Object> get props => [profiles];
}

/// State when profile creation is in progress
class ProfileCreating extends ProfileState {}

/// State when profile creation is successful
class ProfileCreated extends ProfileState {
  final ProfileModel profile;

  const ProfileCreated(this.profile);

  @override
  List<Object> get props => [profile];
}

/// State when profile update is in progress
class ProfileUpdating extends ProfileState {}

/// State when profile update is successful
class ProfileUpdated extends ProfileState {
  final ProfileModel profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object> get props => [profile];
}

/// State when profile deletion is in progress
class ProfileDeleting extends ProfileState {}

/// State when profile deletion is successful
class ProfileDeleted extends ProfileState {
  final String userId;

  const ProfileDeleted(this.userId);

  @override
  List<Object> get props => [userId];
}

/// State when profile photo upload is in progress
class ProfilePhotoUploading extends ProfileState {}

/// State when profile photo upload is successful
class ProfilePhotoUploaded extends ProfileState {
  final String photoUrl;

  const ProfilePhotoUploaded(this.photoUrl);

  @override
  List<Object> get props => [photoUrl];
}

/// State when profile photo deletion is in progress
class ProfilePhotoDeleting extends ProfileState {}

/// State when profile photo deletion is successful
class ProfilePhotoDeleted extends ProfileState {
  final String photoUrl;

  const ProfilePhotoDeleted(this.photoUrl);

  @override
  List<Object> get props => [photoUrl];
}

/// State when an error occurs
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

/// State when a profile's location has been updated
class ProfileLocationUpdated extends ProfileState {
  /// The updated profile
  final dynamic profile;

  /// Constructor
  const ProfileLocationUpdated(this.profile);

  @override
  List<Object> get props => [profile];
}
