import 'package:get_it/get_it.dart';
import 'package:bond_app/core/services/location_service.dart';
import 'package:bond_app/core/managers/location_manager.dart';
import 'package:bond_app/core/utils/geofencing_util.dart';
import 'package:bond_app/core/services/algolia_service.dart';
import 'package:bond_app/core/services/profile_indexing_service.dart';
import 'package:bond_app/core/services/location_tracking_service.dart';
import 'package:bond_app/features/discovery/data/repositories/discovery_repository.dart';
import 'package:bond_app/features/connections/data/datasources/connection_firestore_datasource.dart';
import 'package:bond_app/features/connections/data/repositories/connection_repository_impl.dart';
import 'package:bond_app/features/connections/domain/repositories/connection_repository.dart';
import 'package:bond_app/features/connections/presentation/bloc/connection_bloc.dart';

/// Global service locator instance
final GetIt serviceLocator = GetIt.instance;

/// Register all dependencies
Future<void> setupServiceLocator() async {
  // Services
  serviceLocator.registerLazySingleton<LocationService>(
    () => GeolocatorService(),
  );
  
  serviceLocator.registerLazySingleton<AlgoliaService>(
    () => AlgoliaServiceImpl(),
  );
  
  serviceLocator.registerLazySingleton<ProfileIndexingService>(
    () => ProfileIndexingService(),
  );
  
  serviceLocator.registerLazySingleton<LocationTrackingService>(
    () => LocationTrackingService(),
  );
  
  // Managers
  serviceLocator.registerLazySingleton<LocationManager>(
    () => LocationManager(serviceLocator<LocationService>()),
  );
  
  // Utils
  serviceLocator.registerLazySingleton<GeofencingUtil>(
    () => GeofencingUtil(serviceLocator<LocationManager>()),
  );
  
  // Repositories
  serviceLocator.registerLazySingleton<DiscoveryRepository>(
    () => AlgoliaDiscoveryRepository(serviceLocator<AlgoliaService>()),
  );
  
  // Connections feature
  serviceLocator.registerLazySingleton<ConnectionFirestoreDataSource>(
    () => ConnectionFirestoreDataSource(),
  );
  
  serviceLocator.registerLazySingleton<ConnectionRepository>(
    () => ConnectionRepositoryImpl(
      dataSource: serviceLocator<ConnectionFirestoreDataSource>(),
    ),
  );
  
  serviceLocator.registerFactory<ConnectionBloc>(
    () => ConnectionBloc(
      connectionRepository: serviceLocator<ConnectionRepository>(),
    ),
  );
  
  // Initialize services
  await _initializeServices();
}

/// Initialize services that require async initialization
Future<void> _initializeServices() async {
  // Initialize Algolia service
  serviceLocator<AlgoliaService>().initialize();
}
