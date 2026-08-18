import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Stream of connectivity change states
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Check current connectivity status
  Future<List<ConnectivityResult>> checkConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (_) {
      return [ConnectivityResult.none];
    }
  }

  /// Convenience helper to determine if there is an active network connection
  static bool hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((result) => result != ConnectivityResult.none);
  }

  /// Check boolean connection directly
  Future<bool> isConnected() async {
    final results = await checkConnectivity();
    return hasConnection(results);
  }
}
