import 'package:algolia/algolia.dart';
import '../../core/config/env_config.dart';

/// A service class to manage Algolia search functionality
class AlgoliaService {
  static AlgoliaService? _instance;
  
  final Algolia _algolia;
  
  Algolia get algolia => _algolia;
  
  AlgoliaService._({required Algolia algolia}) : _algolia = algolia;
  
  /// Initialize Algolia with the stored credentials
  static AlgoliaService initialize() {
    if (_instance != null) return _instance!;
    
    final algolia = Algolia.init(
      applicationId: EnvConfig.algoliaAppId,
      apiKey: EnvConfig.algoliaApiKey,
    );
    
    _instance = AlgoliaService._(algolia: algolia);
    return _instance!;
  }
  
  /// Get the default index for user search
  AlgoliaIndex get usersIndex => _algolia.index(EnvConfig.algoliaIndexName);
  
  /// Search for users with the given query
  Future<AlgoliaQuerySnapshot> searchUsers({
    required String query,
    int? hitsPerPage,
    List<String>? facetFilters,
    Map<String, dynamic>? aroundLatLng,
    int? aroundRadius,
  }) async {
    AlgoliaQuery algoliaQuery = usersIndex.query(query);
    
    // Apply pagination if specified
    if (hitsPerPage != null) {
      algoliaQuery = algoliaQuery.setHitsPerPage(hitsPerPage);
    }
    
    // Apply facet filters if specified
    if (facetFilters != null && facetFilters.isNotEmpty) {
      algoliaQuery = algoliaQuery.setFacetFilter(facetFilters);
    }
    
    // Apply geolocation search if specified
    if (aroundLatLng != null && aroundLatLng.containsKey('lat') && aroundLatLng.containsKey('lng')) {
      final lat = aroundLatLng['lat'];
      final lng = aroundLatLng['lng'];
      algoliaQuery = algoliaQuery.setAroundLatLng('$lat, $lng');
      
      if (aroundRadius != null) {
        algoliaQuery = algoliaQuery.setAroundRadius(aroundRadius);
      }
    }
    
    return await algoliaQuery.getObjects();
  }
  
  /// Index a user in Algolia
  Future<AlgoliaTask> indexUser({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    return await usersIndex.addObject(userData, objectID: userId);
  }
  
  /// Update a user in Algolia
  Future<AlgoliaTask> updateUser({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    return await usersIndex.partialUpdateObject(userData, objectID: userId);
  }
  
  /// Delete a user from Algolia
  Future<AlgoliaTask> deleteUser({required String userId}) async {
    return await usersIndex.deleteObject(userId);
  }
}
