import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:logistics/core/services/firebase_authentication.dart';
import 'package:logistics/core/services/firestore_service.dart';
import 'package:logistics/data/repositories/auth_repository.dart';
import 'package:logistics/domain/repositories/auth_repository.dart' as domain;
import 'package:logistics/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:logistics/presentation/bloc/inventory_bloc/inventory_bloc.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // Register services
  sl.registerLazySingleton<FirebaseAuthenticationService>(() => FirebaseAuthenticationService());
  sl.registerLazySingleton<FirestoreService>(() => FirestoreService(firestore: sl<FirebaseFirestore>()));

  // Register repositories
  sl.registerLazySingleton<domain.AuthRepository>(
    () => AuthRepository(authService: sl<FirebaseAuthenticationService>()),
  );

  // Register BLoC
  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl<domain.AuthRepository>()));
  sl.registerFactory<InventoryBloc>(() => InventoryBloc(firestoreService: sl<FirestoreService>()));

  // Register Firebase
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
}
