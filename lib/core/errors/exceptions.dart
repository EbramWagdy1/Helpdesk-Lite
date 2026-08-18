/// Base application exception
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => message;
}

/// Authentication related exception
class AuthException extends AppException {
  const AuthException({required super.message, super.code});
}

/// Network & Connectivity related exception
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection detected.',
    super.code = 'network-error',
  });
}

/// Firestore database exception
class FirestoreException extends AppException {
  const FirestoreException({required super.message, super.code});
}

/// Storage & Upload exception
class StorageException extends AppException {
  const StorageException({required super.message, super.code});
}

/// Cache / Local storage exception
class CacheException extends AppException {
  const CacheException({
    super.message = 'Failed to read or write local cached data.',
    super.code = 'cache-error',
  });
}

/// Server / Remote service exception
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server response error.',
    super.code = 'server-error',
  });
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});
}

/// Unauthorized / Permission exception
class PermissionException extends AppException {
  const PermissionException({
    super.message = 'Access denied: insufficient permissions.',
    super.code = 'permission-denied',
  });
}

/// Not found exception
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Requested entity not found.',
    super.code = 'not-found',
  });
}
