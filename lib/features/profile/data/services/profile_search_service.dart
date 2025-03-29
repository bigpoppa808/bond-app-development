import 'package:algolia/algolia.dart';
import 'package:bond_app/core/services/algolia_service.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:geolocator/geolocator.dart';

/// Service for managing profile search functionality using Algolia
class ProfileSearchService {
  final AlgoliaService _algoliaService;
  static const String _profilesIndex = 'user_profiles';

  ProfileSearchService({required AlgoliaService algoliaService}) 
      : _algoliaService = algoliaService {
    _algoliaService.initialize();
  }

  /// Index a profile in Algolia for searching
  Future<void> indexProfile(ProfileModel profile) async {
    final profileData = profile.toMap();
    
    // Remove sensitive data that shouldn't be indexed
    profileData.remove('email');
    profileData.remove('phoneNumber');
    
    // Add any additional search-specific fields
    profileData['objectID'] = profile.userId;

    try {
      await _algoliaService.addObject(
        indexName: _profilesIndex,
        object: profileData,
      );
    } catch (e) {
      // Handle the error appropriately
      rethrow;
    }
  }

  /// Update an indexed profile in Algolia
  Future<void> updateProfileIndex(ProfileModel profile) async {
    final profileData = profile.toMap();
    
    // Remove sensitive data that shouldn't be indexed
    profileData.remove('email');
    profileData.remove('phoneNumber');
    
    try {
      await _algoliaService.updateObject(
        indexName: _profilesIndex,
        objectId: profile.userId,
        data: profileData,
      );
    } catch (e) {
      // Handle the error appropriately
      rethrow;
    }
  }

  /// Remove a profile from the search index
  Future<void> removeProfileFromIndex(String userId) async {
    try {
      await _algoliaService.deleteObject(
        indexName: _profilesIndex,
        objectId: userId,
      );
    } catch (e) {
      // Handle the error appropriately
      rethrow;
    }
  }

  /// Update profile location in the search index
  Future<void> updateProfileLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _algoliaService.updateObject(
        indexName: _profilesIndex,
        objectId: userId,
        data: {
          '_geoloc': {
            'lat': latitude,
            'lng': longitude,
          },
          'lastLocationUpdate': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Handle the error appropriately
      rethrow;
    }
  }

  /// Search for profiles by keywords (name, interests, etc.)
  Future<List<ProfileModel>> searchProfiles({
    required String query,
    int hitsPerPage = 20,
    int page = 0,
  }) async {
    try {
      final result = await _algoliaService.search(
        indexName: _profilesIndex,
        query: query,
        hitsPerPage: hitsPerPage,
        page: page,
      );

      return result.hits
          .map((hit) => ProfileModel.fromMap(hit.data))
          .toList();
    } catch (e) {
      // Handle the error appropriately
      rethrow;
    }
  }

  /// Search for profiles within a certain distance of a location
  Future<List<ProfileModel>> searchProfilesByLocation({
    required double latitude,
    required double longitude,
    required int radiusInMeters,
    String query = '',
    int hitsPerPage = 20,
    int page = 0,
  }) async {
    try {
      // Create Algolia geo filter
      final aroundRadius = radiusInMeters;
      final queryWithFilters = _algoliaService.search(
        indexName: _profilesIndex,
        query: query,
        filters: {
          '_geoloc': {
            'lat': latitude,
            'lng': longitude,
            'radius': aroundRadius,
          },
        },
        hitsPerPage: hitsPerPage,
        page: page,
      );

      final result = await queryWithFilters;
      return result.hits
          .map((hit) => ProfileModel.fromMap(hit.data))
          .toList();
    } catch (e) {
      // Handle the error appropriately
      rethrow;
    }
  }

  /// Search for profiles by interests
  Future<List<ProfileModel>> searchProfilesByInterests({
    required List<String> interests,
    String query = '',
    int hitsPerPage = 20,
    int page = 0,
  }) async {
    try {
      final interestsFilter = interests.map((interest) => 'interests:$interest').join(' OR ');
      
      final algoliaQuery = _algoliaService.search(
        indexName: _profilesIndex,
        query: query,
        filters: {'interests': interests},
        hitsPerPage: hitsPerPage,
        page: page,
      );

      final result = await algoliaQuery;
      return result.hits
          .map((hit) => ProfileModel.fromMap(hit.data))
          .toList();
    } catch (e) {
      // Handle the error appropriately
      rethrow;
    }
  }
}
