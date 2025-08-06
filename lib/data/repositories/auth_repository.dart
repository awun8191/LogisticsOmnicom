import 'package:firebase_auth/firebase_auth.dart';
import 'package:logistics/core/services/firebase_authentication.dart';
import 'package:logistics/domain/repositories/auth_repository.dart' as domain;

/// Data layer implementation of the authentication repository
///
/// This repository implements the domain layer interface and acts as an
/// intermediary between the domain layer and the Firebase authentication service,
/// handling data transformation and error mapping.
class AuthRepository implements domain.AuthRepository {
  final FirebaseAuthenticationService _authService;

  AuthRepository({required FirebaseAuthenticationService authService}) : _authService = authService;

  @override
  Future<User> signInWithEmail(String email, String password) async {
    return await _authService.signInWithEmail(email, password);
  }

  @override
  Future<User> signUpWithEmail(String email, String password) async {
    return await _authService.signUpWithEmail(email, password);
  }

  @override
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  User? get currentUser => _authService.currentUser;

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;
}
