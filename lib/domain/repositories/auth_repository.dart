import 'package:firebase_auth/firebase_auth.dart';

/// Abstract repository interface for authentication operations
///
/// This interface defines the contract for authentication operations
/// in the domain layer, following clean architecture principles.
/// The actual implementation will be provided by the data layer.
abstract class AuthRepository {
  /// Signs in a user with email and password
  ///
  /// Returns the authenticated [User] on success
  /// Throws appropriate exceptions on failure
  Future<User> signInWithEmail(String email, String password);

  /// Creates a new user account with email and password
  ///
  /// Returns the newly created [User] on success
  /// Throws appropriate exceptions on failure
  Future<User> signUpWithEmail(String email, String password);

  /// Sends a password reset email to the provided email address
  ///
  /// Throws appropriate exceptions on failure
  Future<void> resetPassword(String email);

  /// Signs out the current user
  ///
  /// Throws appropriate exceptions on failure
  Future<void> signOut();

  /// Gets the currently authenticated user
  ///
  /// Returns [User] if authenticated, null otherwise
  User? get currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
}
