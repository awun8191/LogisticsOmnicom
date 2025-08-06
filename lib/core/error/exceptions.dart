/// Base exception class for all in-app exceptions
class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  AppException(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

/// Authentication-related exceptions

/// Thrown when user provides invalid credentials
class InvalidCredentialsException extends AppException {
  InvalidCredentialsException(super.message, [super.stackTrace]);
}

/// Thrown when user attempts to access a resource without proper authentication
class UnauthorizedException extends AppException {
  UnauthorizedException(super.message, [super.stackTrace]);
}

/// Thrown when user attempts to register with an email that already exists
class EmailAlreadyInUseException extends AppException {
  EmailAlreadyInUseException(super.message, [super.stackTrace]);
}

/// Thrown when user attempts an operation with a weak password
class WeakPasswordException extends AppException {
  WeakPasswordException(super.message, [super.stackTrace]);
}

/// Thrown when user provides an invalid email format
class InvalidEmailException extends AppException {
  InvalidEmailException(super.message, [super.stackTrace]);
}

/// Thrown when user attempts to access an account that is disabled
class UserDisabledException extends AppException {
  UserDisabledException(super.message, [super.stackTrace]);
}

/// Thrown when user is not found
class UserNotFoundException extends AppException {
  UserNotFoundException(super.message, [super.stackTrace]);
}

/// Thrown when too many unsuccessful login attempts have been made
class TooManyRequestsException extends AppException {
  TooManyRequestsException(super.message, [super.stackTrace]);
}

/// Thrown when network connectivity issues occur during authentication
class NetworkException extends AppException {
  NetworkException(super.message, [super.stackTrace]);
}

/// Thrown when authentication operation times out
class TimeoutException extends AppException {
  TimeoutException(super.message, [super.stackTrace]);
}

/// Thrown when an unexpected error occurs during authentication
class AuthenticationException extends AppException {
  AuthenticationException(super.message, [super.stackTrace]);
}
