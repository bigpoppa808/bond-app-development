import 'package:algolia/algolia.dart';
import 'package:bond_app/core/config/env_config.dart';

/// Interface for Algolia search service
abstract class AlgoliaService {
  /// Initialize the Algolia client
  void initialize();

  /// Search for documents in the given index
  Future<AlgoliaQuerySnapshot> search({
    required String indexName,
    required String query,
    Map<String, dynamic>? filters,
    int? hitsPerPage,
    int? page,
  });

  /// Add a document to the given index
  Future<AlgoliaTask> addObject({
    required String indexName,
    required Map<String, dynamic> object,
  });

  /// Update a document in the given index
  Future<AlgoliaTask> updateObject({
    required String indexName,
    required String objectId,
    required Map<String, dynamic> data,
  });

  /// Delete a document from the given index
  Future<AlgoliaTask> deleteObject({
    required String indexName,
    required String objectId,
  });

  /// Batch update documents in the given index
  Future<AlgoliaTask> batchOperation({
    required String indexName,
    required List<Map<String, dynamic>> operations,
  });
}

/// Implementation of Algolia service using Algolia package
class AlgoliaServiceImpl implements AlgoliaService {
  late final Algolia _algolia;

  /// Initializes the Algolia client with application ID and API key
  @override
  void initialize() {
    _algolia = Algolia.init(
      applicationId: EnvConfig.algoliaAppId,
      apiKey: EnvConfig.algoliaApiKey,
    );
  }

  /// Initialize with custom app ID and API key
  void initialize({String? appId, String? apiKey}) {
    _algolia = Algolia.init(
      applicationId: appId ?? EnvConfig.algoliaAppId,
      apiKey: apiKey ?? EnvConfig.algoliaApiKey,
    );
  }

  /// Search for documents in the given index
  @override
  Future<AlgoliaQuerySnapshot> search({
    required String indexName,
    required String query,
    Map<String, dynamic>? filters,
    int? hitsPerPage,
    int? page,
  }) async {
    AlgoliaQuery algoliaQuery = _algolia.index(indexName).query(query);

    // Apply filters if provided
    if (filters != null) {
      filters.forEach((key, value) {
        if (value is String) {
          algoliaQuery = algoliaQuery.filters('$key:$value');
        } else if (value is List<String>) {
          final filterString = value.map((v) => '$key:$v').join(' OR ');
          algoliaQuery = algoliaQuery.filters(filterString);
        }
      });
    }

    // Set hits per page if provided
    if (hitsPerPage != null) {
      algoliaQuery = algoliaQuery.setHitsPerPage(hitsPerPage);
    }

    // Set page if provided
    if (page != null) {
      algoliaQuery = algoliaQuery.setPage(page);
    }

    return await algoliaQuery.getObjects();
  }

  /// Add a document to the given index
  @override
  Future<AlgoliaTask> addObject({
    required String indexName,
    required Map<String, dynamic> object,
  }) async {
    return await _algolia.index(indexName).addObject(object);
  }

  /// Update a document in the given index
  @override
  Future<AlgoliaTask> updateObject({
    required String indexName,
    required String objectId,
    required Map<String, dynamic> data,
  }) async {
    return await _algolia.index(indexName).updateObject(
      objectId: objectId,
      data: data,
    );
  }

  /// Delete a document from the given index
  @override
  Future<AlgoliaTask> deleteObject({
    required String indexName,
    required String objectId,
  }) async {
    return await _algolia.index(indexName).deleteObject(objectId);
  }

  /// Batch update documents in the given index
  @override
  Future<AlgoliaTask> batchOperation({
    required String indexName,
    required List<Map<String, dynamic>> operations,
  }) async {
    return await _algolia.index(indexName).batch(operations);
  }
}
