import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

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

  /// Get current position with maximum accuracy settings
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.best,
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

      // Get position with best accuracy settings
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: timeLimit ?? const Duration(seconds: 15),
        forceAndroidLocationManager: false, // Use GPS + Network
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

  /// Get address from coordinates (reverse geocoding)
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return _formatAddress(place);
      } else {
        return 'Address not found';
      }
    } catch (e) {
      print('Error getting address: $e');
      return 'Unable to get address: $e';
    }
  }

  /// Get address from current position
  Future<String> getCurrentLocationAddress() async {
    try {
      Position? position = await getCurrentPosition();

      if (position != null) {
        String address = await getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        // Add accuracy and source information for debugging
        String accuracy = position.accuracy.toStringAsFixed(1);
        String source =
            position.isMocked ? ' [EMULATOR/FAKE]' : ' [REAL DEVICE]';

        // Warn if using mocked location
        if (position.isMocked) {
          address = '⚠️ EMULATOR LOCATION (Not Real)\n\n$address';
        }

        return '$address\n\nAccuracy: ${accuracy}m$source\nCoords: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      } else {
        return 'Unable to get current location';
      }
    } catch (e) {
      print('Error getting current location address: $e');
      return 'Error: $e';
    }
  }

  /// Format placemark into readable address
  String _formatAddress(Placemark place) {
    List<String> addressComponents = [];

    // Add street number and name
    if (place.street != null && place.street!.isNotEmpty) {
      addressComponents.add(place.street!);
    }

    // Add sublocality (neighborhood)
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressComponents.add(place.subLocality!);
    }

    // Add locality (city)
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressComponents.add(place.locality!);
    }

    // Add administrative area (state/province)
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      addressComponents.add(place.administrativeArea!);
    }

    // Add country
    if (place.country != null && place.country!.isNotEmpty) {
      addressComponents.add(place.country!);
    }

    // Join components with commas
    return addressComponents.isNotEmpty
        ? addressComponents.join(', ')
        : 'Address not available';
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
