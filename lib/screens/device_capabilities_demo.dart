import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../utils/network_service.dart';
import '../utils/geolocation_service.dart';
import '../utils/camera_service.dart';
import '../utils/accelerometer_service.dart';
import '../utils/battery_service.dart';

class DeviceCapabilitiesDemo extends StatefulWidget {
  const DeviceCapabilitiesDemo({super.key});

  @override
  State<DeviceCapabilitiesDemo> createState() => _DeviceCapabilitiesDemoState();
}

class _DeviceCapabilitiesDemoState extends State<DeviceCapabilitiesDemo> {
  // Service instances
  final NetworkService _networkService = NetworkService();
  final GeolocationService _geolocationService = GeolocationService();
  final CameraService _cameraService = CameraService();
  final AccelerometerService _accelerometerService = AccelerometerService();
  final BatteryService _batteryService = BatteryService();

  // State variables
  String _networkStatus = 'Unknown';
  String _locationStatus = 'Not fetched';
  File? _capturedImage;
  String _accelerometerData = 'Not listening';
  String _gyroscopeData = 'Not listening';
  String _batteryInfo = 'Unknown';
  bool _isListeningToSensors = false;

  // Stream subscriptions
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<BatteryState>? _batterySubscription;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _batterySubscription?.cancel();
    _accelerometerService.dispose();
    _networkService.dispose();
    _batteryService.dispose();
    super.dispose();
  }

  void _initializeServices() {
    _checkNetworkStatus();
    _checkBatteryStatus();
    _listenToNetworkChanges();
    _listenToBatteryChanges();
  }

  // Network functions
  void _checkNetworkStatus() async {
    final status = await _networkService.getConnectivityStatus();
    setState(() {
      _networkStatus = status;
    });
  }

  void _listenToNetworkChanges() {
    _connectivitySubscription = _networkService.connectivityStream.listen((
      result,
    ) {
      _checkNetworkStatus();
    });
  }

  // Location functions
  void _getCurrentLocation() async {
    setState(() {
      _locationStatus = 'Fetching location...';
    });

    try {
      // Get current location address instead of just coordinates
      final address = await _geolocationService.getCurrentLocationAddress();
      setState(() {
        _locationStatus = address;
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Failed to get location: $e';
      });
    }
  }

  // Camera functions
  void _takePhoto() async {
    final image = await _cameraService.takePhoto(imageQuality: 80);
    setState(() {
      _capturedImage = image;
    });

    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo captured successfully!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to capture photo')));
    }
  }

  void _pickImageFromGallery() async {
    final image = await _cameraService.pickImageFromGallery(imageQuality: 80);
    setState(() {
      _capturedImage = image;
    });

    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selected from gallery!')),
      );
    }
  }

  // Sensor functions
  void _toggleSensorListening() {
    if (_isListeningToSensors) {
      _stopSensorListening();
    } else {
      _startSensorListening();
    }
  }

  void _startSensorListening() {
    _accelerometerService.startAccelerometerListening();
    _accelerometerService.startGyroscopeListening();

    _accelerometerSubscription = _accelerometerService.accelerometerStream
        .listen((event) {
          setState(() {
            _accelerometerData = _accelerometerService.formatSensorData(event);
          });
        });

    _gyroscopeSubscription = _accelerometerService.gyroscopeStream.listen((
      event,
    ) {
      setState(() {
        _gyroscopeData = _accelerometerService.formatSensorData(event);
      });
    });

    setState(() {
      _isListeningToSensors = true;
    });
  }

  void _stopSensorListening() {
    _accelerometerService.stopAllSensors();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();

    setState(() {
      _isListeningToSensors = false;
      _accelerometerData = 'Not listening';
      _gyroscopeData = 'Not listening';
    });
  }

  // Battery functions
  void _checkBatteryStatus() async {
    final batteryInfo = await _batteryService.getBatteryInfo();
    setState(() {
      _batteryInfo = _batteryService.formatBatteryInfo(batteryInfo);
    });
  }

  void _listenToBatteryChanges() {
    _batterySubscription = _batteryService.batteryStateStream.listen((state) {
      _checkBatteryStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Capabilities Demo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Network Status Section
            _buildSectionCard(
              title: 'Network Status',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: $_networkStatus',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _checkNetworkStatus,
                    child: const Text('Refresh Network Status'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Location Section
            _buildSectionCard(
              title: 'Geolocation',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location: $_locationStatus',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('Get Current Location'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Camera Section
            _buildSectionCard(
              title: 'Camera',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_capturedImage != null) ...[
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_capturedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _takePhoto,
                          child: const Text('Take Photo'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pickImageFromGallery,
                          child: const Text('Pick from Gallery'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sensors Section
            _buildSectionCard(
              title: 'Motion Sensors',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accelerometer: $_accelerometerData',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gyroscope: $_gyroscopeData',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _toggleSensorListening,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isListeningToSensors ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _isListeningToSensors ? 'Stop Sensors' : 'Start Sensors',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Battery Section
            _buildSectionCard(
              title: 'Battery Status',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Battery: $_batteryInfo',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _checkBatteryStatus,
                    child: const Text('Refresh Battery Status'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Instructions Section
            _buildSectionCard(
              title: 'Usage Instructions',
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Network: Automatically monitors connectivity changes',
                  ),
                  Text('• Location: Tap button to get current GPS coordinates'),
                  Text('• Camera: Take photos or select from gallery'),
                  Text('• Sensors: Start/stop to see real-time motion data'),
                  Text('• Battery: Monitor battery level and charging status'),
                  SizedBox(height: 8),
                  Text(
                    'Note: Make sure to grant necessary permissions when prompted.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }
}
