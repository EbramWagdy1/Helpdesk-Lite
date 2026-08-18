import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:helpdesk/core/errors/exceptions.dart';
import 'package:helpdesk/core/errors/failures.dart';

class ErrorHandler {
  /// Converts any caught error/exception into a domain-level Failure
  static Failure handle(dynamic error) {
    if (error is Failure) {
      return error;
    }

    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthException(error);
    }

    if (error is FirebaseException) {
      return _handleFirebaseException(error);
    }

    if (error is SocketException) {
      return const NetworkFailure(
        message: 'No internet connection. Please check your network and try again.',
        code: 'socket-exception',
      );
    }

    if (error is TimeoutException) {
      return const NetworkFailure(
        message: 'Connection timed out. The server took too long to respond.',
        code: 'timeout',
      );
    }

    if (error is FormatException) {
      return const ValidationFailure(
        message: 'Invalid data format encountered.',
        code: 'format-exception',
      );
    }

    if (error is PlatformException) {
      return UnexpectedFailure(
        message: error.message ?? 'A platform error occurred.',
        code: error.code,
      );
    }

    if (error is AppException) {
      return _handleAppException(error);
    }

    final errorString = error.toString().toLowerCase();

    // Network error string matching fallbacks
    if (errorString.contains('network-request-failed') ||
        errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('clientexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('connection closed') ||
        errorString.contains('offline')) {
      return const NetworkFailure();
    }

    // Permission string matching
    if (errorString.contains('permission-denied') ||
        errorString.contains('unauthorized') ||
        errorString.contains('forbidden')) {
      return const PermissionFailure();
    }

    // Not found string matching
    if (errorString.contains('not-found') || errorString.contains('404')) {
      return const NotFoundFailure();
    }

    // Clean up generic exception string prefixes
    String cleanMessage = error.toString();
    cleanMessage = cleanMessage.replaceAll('Exception: ', '').replaceAll('Error: ', '');

    return UnexpectedFailure(
      message: cleanMessage.isNotEmpty ? cleanMessage : 'An unexpected error occurred.',
    );
  }

  /// Extracts user-friendly error message directly
  static String getErrorMessage(dynamic error) {
    return handle(error).message;
  }

  /// Maps Firebase Auth specific error codes to friendly human-readable strings
  static AuthFailure _handleFirebaseAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code.toLowerCase()) {
      case 'user-not-found':
        message = 'No account found with this email address.';
        break;
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        message = 'Incorrect email or password. Please try again.';
        break;
      case 'email-already-in-use':
      case 'account-exists-with-different-credential':
        message = 'An account is already registered with this email address.';
        break;
      case 'invalid-email':
        message = 'The email address entered is not valid.';
        break;
      case 'user-disabled':
        message = 'This user account has been deactivated. Please contact your manager.';
        break;
      case 'weak-password':
        message = 'Password is too weak. Please use at least 6 characters with numbers or symbols.';
        break;
      case 'operation-not-allowed':
        message = 'This sign-in method is currently disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many failed login attempts. Please wait a few moments and try again.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      case 'requires-recent-login':
        message = 'This operation requires recent authentication. Please sign in again.';
        break;
      case 'channel-error':
        message = 'Please make sure all required fields are filled correctly.';
        break;
      default:
        message = e.message ?? 'Authentication failed. Please verify your credentials.';
    }
    return AuthFailure(message: message, code: e.code);
  }

  /// Maps General Firebase (Firestore, Storage, Functions) exceptions
  static Failure _handleFirebaseException(FirebaseException e) {
    switch (e.plugin) {
      case 'cloud_firestore':
        return _handleFirestoreException(e);
      case 'firebase_storage':
        return _handleStorageException(e);
      default:
        return UnexpectedFailure(
          message: e.message ?? 'A cloud service error occurred.',
          code: e.code,
        );
    }
  }

  /// Handles Cloud Firestore database errors
  static FirestoreFailure _handleFirestoreException(FirebaseException e) {
    String message;
    switch (e.code.toLowerCase()) {
      case 'permission-denied':
        message = 'Permission denied. You do not have access to this document.';
        break;
      case 'not-found':
        message = 'The requested ticket or resource was not found.';
        break;
      case 'already-exists':
        message = 'A resource with this identifier already exists.';
        break;
      case 'resource-exhausted':
        message = 'Database quota exceeded. Please try again later.';
        break;
      case 'unavailable':
      case 'deadline-exceeded':
        message = 'Service temporarily unavailable. Please check your network connection.';
        break;
      case 'unauthenticated':
        message = 'Session expired. Please sign in again.';
        break;
      default:
        message = e.message ?? 'Database operation failed.';
    }
    return FirestoreFailure(message: message, code: e.code);
  }

  /// Handles Firebase Cloud Storage errors
  static StorageFailure _handleStorageException(FirebaseException e) {
    String message;
    switch (e.code.toLowerCase()) {
      case 'unauthorized':
        message = 'You do not have permission to upload or access this file.';
        break;
      case 'quota-exceeded':
        message = 'Storage quota exceeded. Please contact support.';
        break;
      case 'retry-limit-exceeded':
        message = 'Upload timed out. Please check your network connection and retry.';
        break;
      case 'canceled':
        message = 'File upload was cancelled.';
        break;
      case 'object-not-found':
        message = 'The requested file was not found.';
        break;
      default:
        message = e.message ?? 'File upload failed. Please try a different attachment.';
    }
    return StorageFailure(message: message, code: e.code);
  }

  /// Handles custom domain AppExceptions
  static Failure _handleAppException(AppException e) {
    if (e is AuthException) return AuthFailure(message: e.message, code: e.code);
    if (e is NetworkException) return NetworkFailure(message: e.message, code: e.code);
    if (e is FirestoreException) return FirestoreFailure(message: e.message, code: e.code);
    if (e is StorageException) return StorageFailure(message: e.message, code: e.code);
    if (e is CacheException) return CacheFailure(message: e.message, code: e.code);
    if (e is ServerException) return ServerFailure(message: e.message, code: e.code);
    if (e is ValidationException) return ValidationFailure(message: e.message, code: e.code);
    if (e is PermissionException) return PermissionFailure(message: e.message, code: e.code);
    if (e is NotFoundException) return NotFoundFailure(message: e.message, code: e.code);
    return UnexpectedFailure(message: e.message, code: e.code);
  }

  /// Initializes global crash and rendering error handlers for the application
  static void initGlobalErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('[GLOBAL FLUTTER ERROR]: ${details.exceptionAsString()}');
      if (details.stack != null) {
        debugPrint(details.stack.toString());
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[GLOBAL ASYNC ERROR]: $error');
      debugPrint(stack.toString());
      return true;
    };
  }
}

/// Helpful extension methods for easy error conversions
extension ErrorHandlerExtension on Object {
  Failure toFailure() => ErrorHandler.handle(this);
  String toErrorMessage() => ErrorHandler.getErrorMessage(this);
}
