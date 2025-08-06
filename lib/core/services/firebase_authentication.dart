import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../error/exceptions.dart';

/// Service for handling Firebase authentication operations
///
/// This service provides methods for user authentication including:
/// - Email/password sign-in
/// - Email/password registration
/// - Password reset
/// - Sign-out functionality
///
/// All methods throw specific exceptions for different error scenarios
/// instead of returning null or printing errors.
class FirebaseAuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const Duration _timeoutDuration = Duration(seconds: 30);

  /// Returns the currently signed-in user, or null if no user is signed in
  User? get currentUser => _auth.currentUser;

  /// Stream that emits the current user state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Validates email format using regex
  ///
  /// Throws [InvalidEmailException] if the email format is invalid
  void _validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );

    if (email.isEmpty) {
      throw InvalidEmailException('Email cannot be empty');
    }

    if (!emailRegex.hasMatch(email)) {
      throw InvalidEmailException('Invalid email format');
    }
  }

  /// Validates password strength
  ///
  /// Throws [WeakPasswordException] if the password is too weak
  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw WeakPasswordException('Password cannot be empty');
    }

    if (password.length < 6) {
      throw WeakPasswordException('Password must be at least 6 characters long');
    }
  }

  /// Maps FirebaseAuthException to specific app exceptions
  ///
  /// This method provides comprehensive error mapping for all known
  /// Firebase authentication error codes
  AppException _mapFirebaseAuthException(FirebaseAuthException e) {
    debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');

    switch (e.code) {
      case 'invalid-email':
        return InvalidEmailException('The email address is not valid', e.stackTrace);
      case 'user-disabled':
        return UserDisabledException('This user account has been disabled', e.stackTrace);
      case 'user-not-found':
        return UserNotFoundException('No user found with this email address', e.stackTrace);
      case 'wrong-password':
        return InvalidCredentialsException('Invalid password provided', e.stackTrace);
      case 'email-already-in-use':
        return EmailAlreadyInUseException(
          'An account already exists with this email address',
          e.stackTrace,
        );
      case 'operation-not-allowed':
        return AuthenticationException('Email/password accounts are not enabled', e.stackTrace);
      case 'weak-password':
        return WeakPasswordException('The password provided is too weak', e.stackTrace);
      case 'too-many-requests':
        return TooManyRequestsException(
          'Too many unsuccessful login attempts. Please try again later',
          e.stackTrace,
        );
      case 'network-request-failed':
        return NetworkException(
          'Network error occurred. Please check your internet connection',
          e.stackTrace,
        );
      case 'timeout':
        return TimeoutException('The operation timed out. Please try again', e.stackTrace);
      default:
        return AuthenticationException(
          'An unexpected authentication error occurred: ${e.message}',
          e.stackTrace,
        );
    }
  }

  /// Signs in a user with email and password
  ///
  /// Validates input parameters and attempts to sign in the user.
  ///
  /// @param email The user's email address
  /// @param password The user's password
  /// @return The signed-in user
  /// @throws [InvalidEmailException] if email format is invalid
  /// @throws [WeakPasswordException] if password is empty
  /// @throws [InvalidCredentialsException] if credentials are invalid
  /// @throws [UserNotFoundException] if user doesn't exist
  /// @throws [UserDisabledException] if user account is disabled
  /// @throws [NetworkException] if network error occurs
  /// @throws [TimeoutException] if operation times out
  /// @throws [AuthenticationException] for other authentication errors
  Future<User> signInWithEmail(String email, String password) async {
    _validateEmail(email);
    _validatePassword(password);

    try {
      debugPrint('Attempting to sign in user with email: $email');

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(_timeoutDuration);

      final User user = userCredential.user!;
      debugPrint('Successfully signed in user: ${user.uid}');

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on TimeoutException catch (e) {
      throw TimeoutException('Sign-in operation timed out. Please try again', e.stackTrace);
    } catch (e) {
      debugPrint('Unexpected error during sign-in: $e');
      throw AuthenticationException(
        'An unexpected error occurred during sign-in: $e',
        StackTrace.current,
      );
    }
  }

  /// Creates a new user account with email and password
  ///
  /// Validates input parameters and attempts to create a new user account.
  ///
  /// @param email The user's email address
  /// @param password The user's password
  /// @return The newly created user
  /// @throws [InvalidEmailException] if email format is invalid
  /// @throws [WeakPasswordException] if password is too weak
  /// @throws [EmailAlreadyInUseException] if email is already registered
  /// @throws [NetworkException] if network error occurs
  /// @throws [TimeoutException] if operation times out
  /// @throws [AuthenticationException] for other authentication errors
  Future<User> signUpWithEmail(String email, String password) async {
    _validateEmail(email);
    _validatePassword(password);

    try {
      debugPrint('Attempting to create new user with email: $email');

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(_timeoutDuration);

      final User user = userCredential.user!;
      debugPrint('Successfully created new user: ${user.uid}');

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on TimeoutException catch (e) {
      throw TimeoutException('Sign-up operation timed out. Please try again', e.stackTrace);
    } catch (e) {
      debugPrint('Unexpected error during sign-up: $e');
      throw AuthenticationException(
        'An unexpected error occurred during sign-up: $e',
        StackTrace.current,
      );
    }
  }

  /// Sends a password reset email to the specified email address
  ///
  /// Validates the email format and sends a password reset email.
  ///
  /// @param email The email address to send the reset email to
  /// @throws [InvalidEmailException] if email format is invalid
  /// @throws [UserNotFoundException] if no user exists with this email
  /// @throws [NetworkException] if network error occurs
  /// @throws [TimeoutException] if operation times out
  /// @throws [AuthenticationException] for other authentication errors
  Future<void> resetPassword(String email) async {
    _validateEmail(email);

    try {
      debugPrint('Sending password reset email to: $email');

      await _auth.sendPasswordResetEmail(email: email).timeout(_timeoutDuration);

      debugPrint('Successfully sent password reset email to: $email');
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on TimeoutException catch (e) {
      throw TimeoutException('Password reset operation timed out. Please try again', e.stackTrace);
    } catch (e) {
      debugPrint('Unexpected error during password reset: $e');
      throw AuthenticationException(
        'An unexpected error occurred during password reset: $e',
        StackTrace.current,
      );
    }
  }

  /// Signs out the current user
  ///
  /// Signs out the currently authenticated user and clears any cached credentials.
  ///
  /// @throws [AuthenticationException] if sign-out fails
  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      debugPrint('Signing out user: ${user?.uid}');

      await _auth.signOut();

      debugPrint('Successfully signed out');
    } catch (e) {
      debugPrint('Error during sign-out: $e');
      throw AuthenticationException('Failed to sign out: $e', StackTrace.current);
    }
  }
}
