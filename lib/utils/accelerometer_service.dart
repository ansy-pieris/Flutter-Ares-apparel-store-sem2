import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

/// Service class to handle accelerometer and gyroscope data
class AccelerometerService {
  static final AccelerometerService _instance =
      AccelerometerService._internal();
  factory AccelerometerService() => _instance;
  AccelerometerService._internal();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  // Controllers for broadcasting sensor data
  final StreamController<AccelerometerEvent> _accelerometerController =
      StreamController<AccelerometerEvent>.broadcast();
  final StreamController<GyroscopeEvent> _gyroscopeController =
      StreamController<GyroscopeEvent>.broadcast();
  final StreamController<UserAccelerometerEvent> _userAccelerometerController =
      StreamController<UserAccelerometerEvent>.broadcast();
  final StreamController<MagnetometerEvent> _magnetometerController =
      StreamController<MagnetometerEvent>.broadcast();
  final StreamController<Map<String, dynamic>> _motionController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Latest sensor values
  AccelerometerEvent? _latestAccelerometer;
  GyroscopeEvent? _latestGyroscope;
  UserAccelerometerEvent? _latestUserAccelerometer;
  MagnetometerEvent? _latestMagnetometer;

  /// Stream to listen to accelerometer events
  Stream<AccelerometerEvent> get accelerometerStream =>
      _accelerometerController.stream;

  /// Stream to listen to gyroscope events
  Stream<GyroscopeEvent> get gyroscopeStream => _gyroscopeController.stream;

  /// Stream to listen to user accelerometer events (without gravity)
  Stream<UserAccelerometerEvent> get userAccelerometerStream =>
      _userAccelerometerController.stream;

  /// Stream to listen to magnetometer events
  Stream<MagnetometerEvent> get magnetometerStream =>
      _magnetometerController.stream;

  /// Stream to listen to combined motion data
  Stream<Map<String, dynamic>> get motionStream => _motionController.stream;

  /// Start listening to accelerometer events
  void startAccelerometerListening({Duration? interval}) {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: interval ?? const Duration(milliseconds: 100),
    ).listen((AccelerometerEvent event) {
      _latestAccelerometer = event;
      _accelerometerController.add(event);
      _updateMotionData();
    });
  }

  /// Start listening to gyroscope events
  void startGyroscopeListening({Duration? interval}) {
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = gyroscopeEventStream(
      samplingPeriod: interval ?? const Duration(milliseconds: 100),
    ).listen((GyroscopeEvent event) {
      _latestGyroscope = event;
      _gyroscopeController.add(event);
      _updateMotionData();
    });
  }

  /// Start listening to user accelerometer events (without gravity)
  void startUserAccelerometerListening({Duration? interval}) {
    _userAccelerometerSubscription?.cancel();
    _userAccelerometerSubscription = userAccelerometerEventStream(
      samplingPeriod: interval ?? const Duration(milliseconds: 100),
    ).listen((UserAccelerometerEvent event) {
      _latestUserAccelerometer = event;
      _userAccelerometerController.add(event);
      _updateMotionData();
    });
  }

  /// Start listening to magnetometer events
  void startMagnetometerListening({Duration? interval}) {
    _magnetometerSubscription?.cancel();
    _magnetometerSubscription = magnetometerEventStream(
      samplingPeriod: interval ?? const Duration(milliseconds: 100),
    ).listen((MagnetometerEvent event) {
      _latestMagnetometer = event;
      _magnetometerController.add(event);
      _updateMotionData();
    });
  }

  /// Start listening to all sensors
  void startAllSensors({Duration? interval}) {
    startAccelerometerListening(interval: interval);
    startGyroscopeListening(interval: interval);
    startUserAccelerometerListening(interval: interval);
    startMagnetometerListening(interval: interval);
  }

  /// Stop accelerometer listening
  void stopAccelerometerListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  /// Stop gyroscope listening
  void stopGyroscopeListening() {
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;
  }

  /// Stop user accelerometer listening
  void stopUserAccelerometerListening() {
    _userAccelerometerSubscription?.cancel();
    _userAccelerometerSubscription = null;
  }

  /// Stop magnetometer listening
  void stopMagnetometerListening() {
    _magnetometerSubscription?.cancel();
    _magnetometerSubscription = null;
  }

  /// Stop all sensor listening
  void stopAllSensors() {
    stopAccelerometerListening();
    stopGyroscopeListening();
    stopUserAccelerometerListening();
    stopMagnetometerListening();
  }

  /// Get latest accelerometer data
  AccelerometerEvent? get latestAccelerometerData => _latestAccelerometer;

  /// Get latest gyroscope data
  GyroscopeEvent? get latestGyroscopeData => _latestGyroscope;

  /// Get latest user accelerometer data
  UserAccelerometerEvent? get latestUserAccelerometerData =>
      _latestUserAccelerometer;

  /// Get latest magnetometer data
  MagnetometerEvent? get latestMagnetometerData => _latestMagnetometer;

  /// Calculate accelerometer magnitude
  double calculateAccelerometerMagnitude(AccelerometerEvent event) {
    return sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
  }

  /// Calculate gyroscope magnitude
  double calculateGyroscopeMagnitude(GyroscopeEvent event) {
    return sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
  }

  /// Detect shake based on accelerometer data
  bool detectShake(AccelerometerEvent event, {double threshold = 15.0}) {
    double magnitude = calculateAccelerometerMagnitude(event);
    return magnitude > threshold;
  }

  /// Get device orientation based on accelerometer
  String getDeviceOrientation(AccelerometerEvent event) {
    double x = event.x.abs();
    double y = event.y.abs();
    double z = event.z.abs();

    if (z > x && z > y) {
      return event.z > 0 ? 'Face Down' : 'Face Up';
    } else if (x > y) {
      return event.x > 0 ? 'Landscape Left' : 'Landscape Right';
    } else {
      return event.y > 0 ? 'Portrait Upside Down' : 'Portrait';
    }
  }

  /// Calculate device tilt angle in degrees
  double calculateTiltAngle(AccelerometerEvent event) {
    return atan2(event.x, event.z) * 180 / pi;
  }

  /// Update combined motion data
  void _updateMotionData() {
    if (_latestAccelerometer != null || _latestGyroscope != null) {
      Map<String, dynamic> motionData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'accelerometer':
            _latestAccelerometer != null
                ? {
                  'x': _latestAccelerometer!.x,
                  'y': _latestAccelerometer!.y,
                  'z': _latestAccelerometer!.z,
                  'magnitude': calculateAccelerometerMagnitude(
                    _latestAccelerometer!,
                  ),
                  'orientation': getDeviceOrientation(_latestAccelerometer!),
                  'tiltAngle': calculateTiltAngle(_latestAccelerometer!),
                }
                : null,
        'gyroscope':
            _latestGyroscope != null
                ? {
                  'x': _latestGyroscope!.x,
                  'y': _latestGyroscope!.y,
                  'z': _latestGyroscope!.z,
                  'magnitude': calculateGyroscopeMagnitude(_latestGyroscope!),
                }
                : null,
        'userAccelerometer':
            _latestUserAccelerometer != null
                ? {
                  'x': _latestUserAccelerometer!.x,
                  'y': _latestUserAccelerometer!.y,
                  'z': _latestUserAccelerometer!.z,
                }
                : null,
        'magnetometer':
            _latestMagnetometer != null
                ? {
                  'x': _latestMagnetometer!.x,
                  'y': _latestMagnetometer!.y,
                  'z': _latestMagnetometer!.z,
                }
                : null,
      };
      _motionController.add(motionData);
    }
  }

  /// Format sensor data for display
  String formatSensorData(dynamic event) {
    if (event is AccelerometerEvent) {
      return 'X: ${event.x.toStringAsFixed(2)}, Y: ${event.y.toStringAsFixed(2)}, Z: ${event.z.toStringAsFixed(2)}';
    } else if (event is GyroscopeEvent) {
      return 'X: ${event.x.toStringAsFixed(2)}, Y: ${event.y.toStringAsFixed(2)}, Z: ${event.z.toStringAsFixed(2)}';
    } else if (event is UserAccelerometerEvent) {
      return 'X: ${event.x.toStringAsFixed(2)}, Y: ${event.y.toStringAsFixed(2)}, Z: ${event.z.toStringAsFixed(2)}';
    } else if (event is MagnetometerEvent) {
      return 'X: ${event.x.toStringAsFixed(2)}, Y: ${event.y.toStringAsFixed(2)}, Z: ${event.z.toStringAsFixed(2)}';
    }
    return 'Unknown sensor data';
  }

  /// Dispose all resources
  void dispose() {
    stopAllSensors();
    _accelerometerController.close();
    _gyroscopeController.close();
    _userAccelerometerController.close();
    _magnetometerController.close();
    _motionController.close();
  }
}
