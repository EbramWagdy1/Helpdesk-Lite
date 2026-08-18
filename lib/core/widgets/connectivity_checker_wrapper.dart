import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:helpdesk/core/services/connectivity_service.dart';
import 'package:helpdesk/core/services/service_locator.dart';
import 'package:helpdesk/core/widgets/no_internet_404_widget.dart';

class ConnectivityCheckerWrapper extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, VoidCallback onRetry)? offlineBuilder;
  final bool isFullScreen;

  const ConnectivityCheckerWrapper({
    super.key,
    required this.child,
    this.offlineBuilder,
    this.isFullScreen = true,
  });

  @override
  State<ConnectivityCheckerWrapper> createState() => _ConnectivityCheckerWrapperState();
}

class _ConnectivityCheckerWrapperState extends State<ConnectivityCheckerWrapper> {
  late final ConnectivityService _connectivityService;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _connectivityService = sl.isRegistered<ConnectivityService>()
        ? sl<ConnectivityService>()
        : ConnectivityService();

    _initConnectivity();
    _subscription = _connectivityService.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivityService.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isLoading = false;
        });
      }
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final connected = ConnectivityService.hasConnection(results);
    if (mounted) {
      setState(() {
        _isConnected = connected;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRetry() async {
    final results = await _connectivityService.checkConnectivity();
    _updateConnectionStatus(results);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.child;
    }

    if (!_isConnected) {
      if (widget.offlineBuilder != null) {
        return widget.offlineBuilder!(context, _handleRetry);
      }
      return NoInternet404Widget(
        isFullScreen: widget.isFullScreen,
        onRetry: _handleRetry,
      );
    }

    return widget.child;
  }
}
