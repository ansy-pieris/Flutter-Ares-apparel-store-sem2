import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service class to handle device geolocation
class GeolocationService {
  static final GeolocationService _instance = GeolocationService._internal();
  factory GeolocationService() => _instance;
  GeolocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Get current position with error handling
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      // Check permissions
      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeLimit,
      );

      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Get position stream for real-time tracking
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    Duration? timeInterval,
  }) {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate bearing between two points
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get formatted address-like string from coordinates
  String formatPosition(Position position) {
    return 'Lat: ${position.latitude.toStringAsFixed(6)}, '
        'Lng: ${position.longitude.toStringAsFixed(6)}, '
        'Accuracy: ${position.accuracy.toStringAsFixed(1)}m';
  }

  /// Open device location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings for location permission
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
