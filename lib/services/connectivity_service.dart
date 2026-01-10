import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/logging/logger.dart';

/// Connectivity service for monitoring network status
class ConnectivityService {
  final Connectivity _connectivity;
  final Logger _logger;
  final StreamController<ConnectivityResult> _connectivityController =
      StreamController.broadcast();

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  ConnectivityService(this._connectivity, this._logger);

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (ConnectivityResult result) {
          _logger.info('Connectivity changed: $result');
          _connectivityController.add(result);
        },
        onError: (error) {
          _logger.error('Connectivity monitoring error', error);
        },
      );

      _logger.info('Connectivity service initialized');
    } catch (e) {
      _logger.error('Failed to initialize connectivity service', e);
    }
  }

  /// Get current connectivity status
  Future<ConnectivityResult> getCurrentConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      _logger.error('Failed to check connectivity', e);
      return ConnectivityResult.none;
    }
  }

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivityController.stream;

  /// Check if device is connected to internet
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await getCurrentConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Additional check for actual internet connectivity
      return await _hasInternetConnection();
    } catch (e) {
      _logger.error('Failed to check internet connection', e);
      return false;
    }
  }

  /// Check if device has internet access by pinging a reliable host
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Check if connected via WiFi
  Future<bool> isConnectedViaWifi() async {
    final result = await getCurrentConnectivity();
    return result == ConnectivityResult.wifi;
  }

  /// Check if connected via mobile data
  Future<bool> isConnectedViaMobile() async {
    final result = await getCurrentConnectivity();
    return result == ConnectivityResult.mobile;
  }

  /// Check if connected via ethernet
  Future<bool> isConnectedViaEthernet() async {
    final result = await getCurrentConnectivity();
    return result == ConnectivityResult.ethernet;
  }

  /// Get connection type description
  String getConnectionTypeDescription(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.none:
        return 'No Connection';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
    }
  }

  /// Monitor connectivity with periodic checks
  Stream<ConnectivityStatus> monitorConnectivity({
    Duration checkInterval = const Duration(seconds: 30),
  }) async* {
    while (true) {
      final connectivityResult = await getCurrentConnectivity();
      final hasInternet =
          connectivityResult != ConnectivityResult.none
              ? await _hasInternetConnection()
              : false;

      yield ConnectivityStatus(
        result: connectivityResult,
        hasInternet: hasInternet,
        timestamp: DateTime.now(),
      );

      await Future.delayed(checkInterval);
    }
  }

  /// Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
    _logger.info('Connectivity service disposed');
  }
}

/// Connectivity status information
class ConnectivityStatus {
  final ConnectivityResult result;
  final bool hasInternet;
  final DateTime timestamp;

  ConnectivityStatus({
    required this.result,
    required this.hasInternet,
    required this.timestamp,
  });

  /// Check if connected to any network
  bool get isConnected => result != ConnectivityResult.none;

  /// Check if connected and has internet
  bool get isOnline => isConnected && hasInternet;

  /// Check if offline
  bool get isOffline => !isOnline;

  /// Get connection quality estimate
  ConnectionQuality get quality {
    if (isOffline) return ConnectionQuality.none;

    // Estimate quality based on connection type
    switch (result) {
      case ConnectivityResult.wifi:
        // WiFi is generally good, but we could add ping tests here
        return ConnectionQuality.excellent;
      case ConnectivityResult.mobile:
        // Mobile can vary, but assume good for LTE/5G
        return ConnectionQuality.good;
      case ConnectivityResult.ethernet:
        // Ethernet is typically excellent
        return ConnectionQuality.excellent;
      case ConnectivityResult.vpn:
        // VPN might have some latency but generally good
        return ConnectionQuality.good;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.other:
        // These are typically slower
        return ConnectionQuality.poor;
      case ConnectivityResult.none:
        return ConnectionQuality.none;
    }
  }

  @override
  String toString() {
    return 'ConnectivityStatus(result: $result, hasInternet: $hasInternet, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectivityStatus &&
        other.result == result &&
        other.hasInternet == hasInternet;
  }

  @override
  int get hashCode => result.hashCode ^ hasInternet.hashCode;
}

/// Connection quality levels
enum ConnectionQuality { none, poor, fair, good, excellent }

/// Connectivity utilities
class ConnectivityUtils {
  /// Get recommended timeout based on connection type
  static Duration getRecommendedTimeout(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        return const Duration(seconds: 10);
      case ConnectivityResult.mobile:
        return const Duration(seconds: 15);
      case ConnectivityResult.bluetooth:
        return const Duration(seconds: 20);
      case ConnectivityResult.vpn:
        return const Duration(seconds: 12);
      case ConnectivityResult.none:
      case ConnectivityResult.other:
        return const Duration(seconds: 30);
    }
  }

  /// Check if connection type supports large file uploads
  static bool supportsLargeUploads(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn;
  }

  /// Get connection speed estimate (rough)
  static String getSpeedEstimate(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'Fast';
      case ConnectivityResult.ethernet:
        return 'Very Fast';
      case ConnectivityResult.mobile:
        return 'Variable';
      case ConnectivityResult.bluetooth:
        return 'Slow';
      case ConnectivityResult.vpn:
        return 'Variable';
      case ConnectivityResult.none:
        return 'None';
      case ConnectivityResult.other:
        return 'Unknown';
    }
  }

  /// Check if should retry request based on connectivity
  static bool shouldRetryOnConnectivity(
    ConnectivityResult result,
    int attemptNumber,
  ) {
    if (result == ConnectivityResult.none) return false;

    // Retry up to 3 times for poor connections
    return attemptNumber < 3;
  }
}
