import 'dart:io';

import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:bond_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Firebase implementation of the profile repository
class FirebaseProfileRepository implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  
  /// Collection reference for profiles in Firestore
  final CollectionReference _profilesCollection;
  
  /// Constructor
  FirebaseProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _storage = storage ?? FirebaseStorage.instance,
    _profilesCollection = (firestore ?? FirebaseFirestore.instance).collection('profiles');
  
  @override
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final profileDoc = await _profilesCollection.doc(userId).get();
      
      if (!profileDoc.exists) {
        return null;
      }
      
      return ProfileModel.fromFirestore(profileDoc);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }
  
  @override
  Future<ProfileModel> createProfile(ProfileModel profile) async {
    try {
      // Check if profile already exists
      final exists = await profileExists(profile.userId);
      
      if (exists) {
        throw Exception('Profile already exists for this user');
      }
      
      // Create profile with server timestamp
      final newProfile = profile.copyWith(
        lastUpdated: DateTime.now(),
      );
      
      await _profilesCollection.doc(profile.userId).set(newProfile.toFirestore());
      
      return newProfile;
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }
  
  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      // Check if profile exists
      final exists = await profileExists(profile.userId);
      
      if (!exists) {
        throw Exception('Profile does not exist for this user');
      }
      
      // Update profile with server timestamp
      final updatedProfile = profile.copyWith(
        lastUpdated: DateTime.now(),
      );
      
      await _profilesCollection.doc(profile.userId).update(updatedProfile.toFirestore());
      
      return updatedProfile;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  @override
  Future<void> deleteProfile(String userId) async {
    try {
      await _profilesCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }
  
  @override
  Future<String> uploadProfilePhoto(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final uuid = const Uuid().v4();
      final extension = filePath.split('.').last;
      final fileName = '$userId/profile_photos/$uuid.$extension';
      
      // Upload file to Firebase Storage
      final storageRef = _storage.ref().child(fileName);
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update profile with new photo
      final profile = await getProfile(userId);
      
      if (profile != null) {
        final updatedPhotos = List<String>.from(profile.photos)..add(downloadUrl);
        await updateProfile(profile.copyWith(photos: updatedPhotos));
      }
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }
  
  @override
  Future<void> deleteProfilePhoto(String userId, String photoUrl) async {
    try {
      // Delete from Storage if it's a Firebase Storage URL
      if (photoUrl.contains('firebasestorage.googleapis.com')) {
        final ref = _storage.refFromURL(photoUrl);
        await ref.delete();
      }
      
      // Update profile to remove photo
      final profile = await getProfile(userId);
      
      if (profile != null) {
        final updatedPhotos = List<String>.from(profile.photos)..remove(photoUrl);
        await updateProfile(profile.copyWith(photos: updatedPhotos));
      }
    } catch (e) {
      throw Exception('Failed to delete profile photo: $e');
    }
  }
  
  @override
  Future<List<ProfileModel>> getProfilesByInterests(List<String> interests, {int limit = 10}) async {
    try {
      if (interests.isEmpty) {
        return [];
      }
      
      // Use array-contains-any to find profiles with matching interests
      // Note: Firebase only supports up to 10 values in array-contains-any
      final limitedInterests = interests.take(10).toList();
      
      final querySnapshot = await _profilesCollection
          .where('hobbies', arrayContainsAny: limitedInterests)
          .where('isPublic', isEqualTo: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ProfileModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get profiles by interests: $e');
    }
  }
  
  @override
  Future<bool> profileExists(String userId) async {
    try {
      final profileDoc = await _profilesCollection.doc(userId).get();
      return profileDoc.exists;
    } catch (e) {
      throw Exception('Failed to check if profile exists: $e');
    }
  }
}
