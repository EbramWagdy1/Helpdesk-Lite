abstract class Failure {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ (code?.hashCode ?? 0);
}

/// Authentication & Authorization Failures (Firebase Auth / Token / Session)
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Network & Connectivity Failures (No Internet, Connection Timeout, Socket)
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Please check your internet connection and try again.',
    super.code = 'no-internet',
  });
}

/// Cloud Firestore / Database Failures
class FirestoreFailure extends Failure {
  const FirestoreFailure({required super.message, super.code});
}

/// Firebase Cloud Storage / Media Upload Failures
class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});
}

/// Local Cache / SharedPreferences Failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Local cache error occurred.',
    super.code = 'cache-error',
  });
}

/// Backend / Server Failures
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'A server error occurred. Please try again later.',
    super.code = 'server-error',
  });
}

/// Form / Data Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Permission / Role-Based Access Failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'permission-denied',
  });
}

/// Resource / Document Not Found Failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code = 'not-found',
  });
}

/// Catch-all Unknown Failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'unknown-error',
  });
}
