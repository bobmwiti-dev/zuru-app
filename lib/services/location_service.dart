import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../core/logging/logger.dart';
import '../core/exceptions/app_exception.dart';

/// Location service for GPS and geocoding operations
class LocationService {
  final GeolocatorPlatform _geolocator;
  final Logger _logger;

  LocationService(this._geolocator, this._logger);

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await _geolocator.isLocationServiceEnabled();
    } catch (e) {
      _logger.error('Failed to check location service status', e);
      return false;
    }
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    try {
      return await _geolocator.requestPermission();
    } catch (e) {
      _logger.error('Failed to request location permission', e);
      throw PermissionException(
        message: 'Failed to request location permission',
      );
    }
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    try {
      return await _geolocator.checkPermission();
    } catch (e) {
      _logger.error('Failed to check location permission', e);
      throw PermissionException(message: 'Failed to check location permission');
    }
  }

  /// Get current position
  Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw PermissionException(message: 'Location services are disabled');
      }

      // Check permission
      final permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        throw PermissionException(message: 'Location permission denied');
      }
      if (permission == LocationPermission.deniedForever) {
        throw PermissionException(
          message: 'Location permission permanently denied',
        );
      }

      // Get position
      return await _geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeLimit,
        ),
      );
    } catch (e) {
      _logger.error('Failed to get current position', e);

      if (e is PermissionException) {
        rethrow;
      }

      throw NetworkException(
        message: 'Failed to get current location',
        originalException: e,
      );
    }
  }

  /// Get last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      return await _geolocator.getLastKnownPosition();
    } catch (e) {
      _logger.error('Failed to get last known position', e);
      return null;
    }
  }

  /// Get position stream
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 0,
    Duration interval = const Duration(seconds: 1),
  }) {
    try {
      return _geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
        ),
      );
    } catch (e) {
      _logger.error('Failed to get position stream', e);
      throw NetworkException(
        message: 'Failed to start location tracking',
        originalException: e,
      );
    }
  }

  /// Get address from coordinates
  Future<List<Placemark>> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await placemarkFromCoordinates(latitude, longitude);
    } catch (e) {
      _logger.error('Failed to get address from coordinates', e);
      throw NetworkException(
        message: 'Failed to get address',
        originalException: e,
      );
    }
  }

  /// Get coordinates from address
  Future<List<Location>> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      _logger.error('Failed to get coordinates from address', e);
      throw NetworkException(
        message: 'Failed to find location',
        originalException: e,
      );
    }
  }

  /// Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return _geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Check if coordinates are within bounds
  bool isWithinBounds({
    required double latitude,
    required double longitude,
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) {
    return latitude >= minLat &&
        latitude <= maxLat &&
        longitude >= minLng &&
        longitude <= maxLng;
  }

  /// Format coordinates for display
  String formatCoordinates(
    double latitude,
    double longitude, {
    int decimals = 6,
  }) {
    return '${latitude.toStringAsFixed(decimals)}, ${longitude.toStringAsFixed(decimals)}';
  }

  /// Get formatted address from placemark
  String getFormattedAddress(Placemark placemark) {
    final components = [
      placemark.name,
      placemark.street,
      placemark.locality,
      placemark.administrativeArea,
      placemark.country,
    ].where((component) => component != null && component.isNotEmpty);

    return components.join(', ');
  }

  /// Validate coordinates
  bool areValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}

/// Location service utilities
class LocationUtils {
  /// Convert degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  /// Convert radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * (180.0 / 3.141592653589793);
  }

  /// Calculate bearing between two points
  static double calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final startLatRad = degreesToRadians(startLat);
    final endLatRad = degreesToRadians(endLat);
    final deltaLngRad = degreesToRadians(endLng - startLng);

    final y = sin(deltaLngRad) * cos(endLatRad);
    final x =
        cos(startLatRad) * sin(endLatRad) -
        sin(startLatRad) * cos(endLatRad) * cos(deltaLngRad);

    final bearingRad = atan2(y, x);
    final bearingDeg = radiansToDegrees(bearingRad);

    return (bearingDeg + 360) % 360;
  }

  /// Check if position is recent (within specified duration)
  static bool isPositionRecent(Position position, Duration maxAge) {
    final now = DateTime.now();
    final positionTime = position.timestamp;
    final age = now.difference(positionTime);

    return age <= maxAge;
  }

  /// Get cardinal direction from bearing
  static String getCardinalDirection(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) % 360 / 45).floor();
    return directions[index % 8];
  }
}
