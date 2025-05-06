import 'package:get_it/get_it.dart';
import 'package:cal_nutri_pal/core/repositories/auth_repository.dart';
import 'package:cal_nutri_pal/core/repositories/database_repository.dart';
import 'package:cal_nutri_pal/core/repositories/storage_repository.dart';
import 'package:cal_nutri_pal/core/services/connectivity_service.dart';
import 'package:cal_nutri_pal/core/services/interfaces/auth_service_interface.dart';
import 'package:cal_nutri_pal/core/services/interfaces/connectivity_service_interface.dart';
import 'package:cal_nutri_pal/core/services/interfaces/database_service_interface.dart';
import 'package:cal_nutri_pal/core/services/interfaces/storage_service_interface.dart';
import 'package:cal_nutri_pal/core/services/mock/mock_auth_service.dart';
import 'package:cal_nutri_pal/core/services/mock/mock_database_service.dart';
import 'package:cal_nutri_pal/core/services/mock/mock_storage_service.dart';

/// Global ServiceLocator instance
final serviceLocator = GetIt.instance;

/// Sets up the service locator with all dependencies
Future<void> setupServiceLocator({bool useMocks = true}) async {
  // Core services
  if (useMocks) {
    // Use mock implementations
    serviceLocator.registerLazySingleton<AuthServiceInterface>(
      () => MockAuthService(),
    );

    serviceLocator.registerLazySingleton<DatabaseServiceInterface>(
      () => MockDatabaseService(),
    );

    serviceLocator.registerLazySingleton<StorageServiceInterface>(
      () => MockStorageService(),
    );
  } else {
    // Use Firebase implementations (we'll implement these later)
    // serviceLocator.registerLazySingleton<AuthServiceInterface>(
    //   () => FirebaseAuthService(),
    // );
    //
    // serviceLocator.registerLazySingleton<DatabaseServiceInterface>(
    //   () => FirestoreService(),
    // );
    //
    // serviceLocator.registerLazySingleton<StorageServiceInterface>(
    //   () => FirebaseStorageService(),
    // );
  }

  // Connectivity service (using real implementation always)
  serviceLocator.registerLazySingleton<ConnectivityServiceInterface>(
    () => ConnectivityService(),
  );

  // Setup repositories
  // We'll register repositories after a user logs in through the initializeUserDependencies function
}

/// Initializes user-specific dependencies after authentication
Future<void> initializeUserDependencies(String userId) async {
  // Register or update user-specific repositories
  if (serviceLocator.isRegistered<AuthRepository>()) {
    serviceLocator.unregister<AuthRepository>();
  }
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(serviceLocator<AuthServiceInterface>()),
  );

  if (serviceLocator.isRegistered<DatabaseRepository>()) {
    serviceLocator.unregister<DatabaseRepository>();
  }
  serviceLocator.registerLazySingleton<DatabaseRepository>(
    () => DatabaseRepository(
      serviceLocator<DatabaseServiceInterface>(),
      userId,
    ),
  );

  if (serviceLocator.isRegistered<StorageRepository>()) {
    serviceLocator.unregister<StorageRepository>();
  }
  serviceLocator.registerLazySingleton<StorageRepository>(
    () => StorageRepository(
      serviceLocator<StorageServiceInterface>(),
      userId,
    ),
  );
}

/// Clears user-specific dependencies on logout
void clearUserDependencies() {
  if (serviceLocator.isRegistered<AuthRepository>()) {
    serviceLocator.unregister<AuthRepository>();
  }

  if (serviceLocator.isRegistered<DatabaseRepository>()) {
    serviceLocator.unregister<DatabaseRepository>();
  }

  if (serviceLocator.isRegistered<StorageRepository>()) {
    serviceLocator.unregister<StorageRepository>();
  }
}
