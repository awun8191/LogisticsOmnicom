import 'package:get_it/get_it.dart';
import 'package:logistics/core/services/firebase_authentication.dart';
import 'package:logistics/data/repositories/auth_repository.dart';
import 'package:logistics/domain/repositories/auth_repository.dart' as domain;
import 'package:logistics/presentation/bloc/auth_bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // Register services
  sl.registerLazySingleton<FirebaseAuthenticationService>(() => FirebaseAuthenticationService());

  // Register repositories
  sl.registerLazySingleton<domain.AuthRepository>(
    () => AuthRepository(authService: sl<FirebaseAuthenticationService>()),
  );

  // Register BLoC
  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl<domain.AuthRepository>()));
}
