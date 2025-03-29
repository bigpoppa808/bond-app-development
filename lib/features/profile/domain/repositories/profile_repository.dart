import 'package:bond_app/features/profile/data/models/profile_model.dart';

/// Interface for profile repository
abstract class ProfileRepository {
  /// Get a profile by user ID
  Future<ProfileModel?> getProfile(String userId);
  
  /// Create a new profile
  Future<ProfileModel> createProfile(ProfileModel profile);
  
  /// Update an existing profile
  Future<ProfileModel> updateProfile(ProfileModel profile);
  
  /// Delete a profile
  Future<void> deleteProfile(String userId);
  
  /// Upload a profile photo
  Future<String> uploadProfilePhoto(String userId, String filePath);
  
  /// Delete a profile photo
  Future<void> deleteProfilePhoto(String userId, String photoUrl);
  
  /// Get profiles by interests
  Future<List<ProfileModel>> getProfilesByInterests(List<String> interests, {int limit = 10});
  
  /// Check if a profile exists
  Future<bool> profileExists(String userId);
}
