import 'package:equatable/equatable.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';

/// Base class for profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load a profile by user ID
class LoadProfile extends ProfileEvent {
  final String userId;

  const LoadProfile(this.userId);

  @override
  List<Object> get props => [userId];
}

/// Event to create a new profile
class CreateProfile extends ProfileEvent {
  final ProfileModel profile;

  const CreateProfile(this.profile);

  @override
  List<Object> get props => [profile];
}

/// Event to update an existing profile
class UpdateProfile extends ProfileEvent {
  final ProfileModel profile;

  const UpdateProfile(this.profile);

  @override
  List<Object> get props => [profile];
}

/// Event to delete a profile
class DeleteProfile extends ProfileEvent {
  final String userId;

  const DeleteProfile(this.userId);

  @override
  List<Object> get props => [userId];
}

/// Event to upload a profile photo
class UploadProfilePhoto extends ProfileEvent {
  final String userId;
  final String filePath;

  const UploadProfilePhoto(this.userId, this.filePath);

  @override
  List<Object> get props => [userId, filePath];
}

/// Event to delete a profile photo
class DeleteProfilePhoto extends ProfileEvent {
  final String userId;
  final String photoUrl;

  const DeleteProfilePhoto(this.userId, this.photoUrl);

  @override
  List<Object> get props => [userId, photoUrl];
}

/// Event to load profiles by interests
class LoadProfilesByInterests extends ProfileEvent {
  final List<String> interests;
  final int limit;

  const LoadProfilesByInterests(this.interests, {this.limit = 10});

  @override
  List<Object> get props => [interests, limit];
}
