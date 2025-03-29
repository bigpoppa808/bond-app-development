import 'package:algolia/algolia.dart';
import 'package:bond_app/core/config/env_config.dart';
import 'package:bond_app/core/services/algolia_service.dart';
import 'package:bond_app/features/profile/domain/models/profile_model.dart';
import 'package:geolocator/geolocator.dart';

/// Interface for discovery repository
abstract class DiscoveryRepository {
  /// Find profiles near a location
  Future<List<ProfileModel>> findProfilesNearLocation({
    required double latitude,
    required double longitude,
    required double radiusInMeters,
    int limit = 20,
    Map<String, dynamic>? filters,
  });
  
  /// Find profiles with matching interests
  Future<List<ProfileModel>> findProfilesByInterests({
    required List<String> interests,
    int limit = 20,
    Map<String, dynamic>? filters,
  });
  
  /// Search profiles by query
  Future<List<ProfileModel>> searchProfiles({
    required String query,
    int limit = 20,
    Map<String, dynamic>? filters,
  });
}

/// Implementation of discovery repository using Algolia
class AlgoliaDiscoveryRepository implements DiscoveryRepository {
  final AlgoliaService _algoliaService;
  final String _indexName;
  
  /// Constructor
  AlgoliaDiscoveryRepository(this._algoliaService, {String? indexName})
      : _indexName = indexName ?? EnvConfig.algoliaIndexName;
  
  @override
  Future<List<ProfileModel>> findProfilesNearLocation({
    required double latitude,
    required double longitude,
    required double radiusInMeters,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    // Convert radius from meters to kilometers for Algolia
    final radiusInKm = radiusInMeters / 1000;
    
    // Create filters map with existing filters
    final searchFilters = <String, dynamic>{
      ...?filters,
    };
    
    // Add privacy filter to only show profiles that are discoverable
    searchFilters['isDiscoverable'] = true;
    
    try {
      final result = await _algoliaService.search(
        indexName: _indexName,
        query: '',
        filters: searchFilters,
        hitsPerPage: limit,
      );
      
      // Apply geo filter using aroundLatLng and aroundRadius parameters
      final algoliaQuery = result.query
          .setAroundLatLng('$latitude, $longitude')
          .setAroundRadius(radiusInKm.round());
      
      final snapshot = await algoliaQuery.getObjects();
      
      return _parseProfileResults(snapshot);
    } catch (e) {
      throw Exception('Failed to find profiles near location: $e');
    }
  }
  
  @override
  Future<List<ProfileModel>> findProfilesByInterests({
    required List<String> interests,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    if (interests.isEmpty) {
      return [];
    }
    
    // Create filters map with existing filters
    final searchFilters = <String, dynamic>{
      ...?filters,
      'hobbies': interests,
    };
    
    // Add privacy filter to only show profiles that are discoverable
    searchFilters['isDiscoverable'] = true;
    
    try {
      final result = await _algoliaService.search(
        indexName: _indexName,
        query: '',
        filters: searchFilters,
        hitsPerPage: limit,
      );
      
      return _parseProfileResults(result);
    } catch (e) {
      throw Exception('Failed to find profiles by interests: $e');
    }
  }
  
  @override
  Future<List<ProfileModel>> searchProfiles({
    required String query,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    if (query.isEmpty) {
      return [];
    }
    
    // Create filters map with existing filters
    final searchFilters = <String, dynamic>{
      ...?filters,
    };
    
    // Add privacy filter to only show profiles that are discoverable
    searchFilters['isDiscoverable'] = true;
    
    try {
      final result = await _algoliaService.search(
        indexName: _indexName,
        query: query,
        filters: searchFilters,
        hitsPerPage: limit,
      );
      
      return _parseProfileResults(result);
    } catch (e) {
      throw Exception('Failed to search profiles: $e');
    }
  }
  
  /// Parse Algolia search results into ProfileModel objects
  List<ProfileModel> _parseProfileResults(AlgoliaQuerySnapshot snapshot) {
    return snapshot.hits.map((hit) {
      final data = hit.data;
      
      // Extract location data if available
      double? latitude;
      double? longitude;
      if (data['_geoloc'] != null) {
        latitude = data['_geoloc']['lat'];
        longitude = data['_geoloc']['lng'];
      }
      
      return ProfileModel.fromJson({
        'id': hit.objectID,
        ...data,
        'latitude': latitude,
        'longitude': longitude,
      });
    }).toList();
  }
}
