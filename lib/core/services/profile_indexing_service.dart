import 'package:bond_app/core/services/algolia_service.dart';
import 'package:bond_app/features/profile/domain/models/profile_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:bond_app/core/config/env_config.dart';

/// Service responsible for indexing user profiles in Algolia for search
class ProfileIndexingService {
  final AlgoliaService _algoliaService;
  final String _indexName;
  
  /// Constructor
  ProfileIndexingService({
    AlgoliaService? algoliaService,
    String? indexName,
  }) : _algoliaService = algoliaService ?? GetIt.I<AlgoliaService>(),
       _indexName = indexName ?? EnvConfig.algoliaIndexName;
  
  /// Index a profile with location data in Algolia
  Future<void> indexProfile(ProfileModel profile, {Position? position}) async {
    try {
      // Prepare the profile data for indexing
      final Map<String, dynamic> indexData = profile.toJson();
      
      // Add geolocation data if available
      if (position != null || (profile.latitude != null && profile.longitude != null)) {
        indexData['_geoloc'] = {
          'lat': position?.latitude ?? profile.latitude,
          'lng': position?.longitude ?? profile.longitude,
        };
      }
      
      // Add additional searchable fields
      indexData['objectID'] = profile.id;
      
      // Only index profiles that are discoverable
      if (profile.isDiscoverable) {
        await _algoliaService.updateObject(
          indexName: _indexName,
          objectId: profile.id,
          data: indexData,
        );
      } else {
        // If profile is not discoverable, remove it from the index
        await _algoliaService.deleteObject(
          indexName: _indexName,
          objectId: profile.id,
        );
      }
    } catch (e) {
      print('Error indexing profile: $e');
      rethrow;
    }
  }
  
  /// Update a profile's location in Algolia
  Future<void> updateProfileLocation(String profileId, Position position) async {
    try {
      await _algoliaService.updateObject(
        indexName: _indexName,
        objectId: profileId,
        data: {
          '_geoloc': {
            'lat': position.latitude,
            'lng': position.longitude,
          },
          'lastLocationUpdate': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error updating profile location: $e');
      rethrow;
    }
  }
  
  /// Remove a profile from the Algolia index
  Future<void> removeProfile(String profileId) async {
    try {
      await _algoliaService.deleteObject(
        indexName: _indexName,
        objectId: profileId,
      );
    } catch (e) {
      print('Error removing profile from index: $e');
      rethrow;
    }
  }
  
  /// Batch index multiple profiles
  Future<void> batchIndexProfiles(List<ProfileModel> profiles) async {
    try {
      final operations = profiles
          .where((profile) => profile.isDiscoverable)
          .map((profile) {
            final data = profile.toJson();
            
            // Add geolocation data if available
            if (profile.latitude != null && profile.longitude != null) {
              data['_geoloc'] = {
                'lat': profile.latitude,
                'lng': profile.longitude,
              };
            }
            
            data['objectID'] = profile.id;
            
            return {
              'action': 'updateObject',
              'body': data,
            };
          })
          .toList();
      
      if (operations.isNotEmpty) {
        await _algoliaService.batchOperation(
          indexName: _indexName,
          operations: operations,
        );
      }
    } catch (e) {
      print('Error batch indexing profiles: $e');
      rethrow;
    }
  }
}
