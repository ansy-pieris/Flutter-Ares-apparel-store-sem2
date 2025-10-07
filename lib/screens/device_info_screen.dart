import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For platform detection
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

/// Screen displaying comprehensive device information
/// Shows GPS location, battery status, motion sensors, and network connectivity
class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  // Location data
  Position? _currentPosition;
  String _locationStatus = 'Press "Get Location" to fetch GPS coordinates';
  String _locationAddress = 'Address not available';
  bool _isGettingLocation = false;

  // Battery data
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;
  bool _batteryInfoLoaded = false;

  // Motion sensor data
  AccelerometerEvent? _accelerometerData;
  GyroscopeEvent? _gyroscopeData;
  bool _sensorsActive = false;

  // Network data
  List<ConnectivityResult> _connectivityResult = [ConnectivityResult.none];
  bool _networkInfoLoaded = false;

  // Stream subscriptions
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Battery instance
  final Battery _battery = Battery();

  @override
  void initState() {
    super.initState();
    _initializeBattery(); // Load battery info on start
    _initializeConnectivity(); // Load network info on start
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Get current GPS location when button is pressed
  Future<void> _getCurrentLocation() async {
    debugPrint('🎯 Get Location button pressed');

    setState(() {
      _isGettingLocation = true;
      _locationStatus = 'Getting location...';
      _locationAddress = 'Getting address...';
    });

    try {
      await _initializeLocation();
    } catch (e) {
      debugPrint('❌ Error in _getCurrentLocation: $e');
      setState(() {
        _locationStatus = 'Failed to get location: $e';
        _locationAddress = 'Address unavailable';
      });
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  /// Start motion sensors when button is pressed
  void _startSensors() {
    if (_sensorsActive) {
      _stopSensors();
      return;
    }

    debugPrint('🎯 Starting motion sensors...');
    setState(() {
      _sensorsActive = true;
    });

    _initializeMotionSensors();
  }

  /// Stop motion sensors with proper cleanup
  void _stopSensors() {
    debugPrint('🛑 Stopping motion sensors...');

    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;

    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;

    setState(() {
      _sensorsActive = false;
      _accelerometerData = null;
      _gyroscopeData = null;
    });

    debugPrint('✅ Motion sensors stopped');
  }

  /// Get address from coordinates using reverse geocoding
  Future<void> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      debugPrint('🔍 Attempting reverse geocoding for: $latitude, $longitude');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      debugPrint('📍 Placemarks found: ${placemarks.length}');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        debugPrint('🏠 Placemark details: $place');

        // Build readable address with null safety
        List<String> addressParts = [];

        // Add each component if it exists and is not empty
        void addIfNotEmpty(String? value) {
          if (value != null && value.trim().isNotEmpty && value != 'null') {
            addressParts.add(value.trim());
          }
        }

        addIfNotEmpty(place.name);
        if (place.street != place.name) addIfNotEmpty(place.street);
        addIfNotEmpty(place.subLocality);
        addIfNotEmpty(place.locality);
        addIfNotEmpty(place.subAdministrativeArea);
        addIfNotEmpty(place.administrativeArea);
        addIfNotEmpty(place.country);

        setState(() {
          if (addressParts.isNotEmpty) {
            _locationAddress = addressParts.join(', ');
            debugPrint('✅ Address resolved: $_locationAddress');
          } else {
            _locationAddress =
                'Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
            debugPrint('⚠️ No address components found, using coordinates');
          }
        });
      } else {
        setState(() {
          _locationAddress =
              'Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
        });
        debugPrint('⚠️ No placemarks found, using coordinates');
      }
    } catch (e) {
      debugPrint('❌ Reverse geocoding error: $e');
      setState(() {
        _locationAddress =
            'Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
      });
    }
  }

  /// Initialize GPS location tracking with enhanced debugging
  Future<void> _initializeLocation() async {
    try {
      debugPrint('📍 Starting location initialization...');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('📡 Location services enabled: $serviceEnabled');

      if (!serviceEnabled) {
        debugPrint('❌ Location services are disabled');
        setState(() {
          _locationStatus =
              'Location services are disabled. Please enable GPS.';
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('🔐 Current location permission: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('🔐 Requesting location permission...');
        permission = await Geolocator.requestPermission();
        debugPrint('🔐 Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          debugPrint('❌ Location permissions denied by user');
          setState(() {
            _locationStatus =
                'Location permissions denied. Please allow location access.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permissions permanently denied');
        setState(() {
          _locationStatus =
              'Location permissions permanently denied. Please enable in settings.';
        });
        return;
      }

      debugPrint('✅ Location permissions granted. Getting current position...');
      setState(() {
        _locationStatus = 'Getting location...';
      });

      // Get current position with timeout
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint(
        '📍 Location obtained: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
      );

      // Get address from coordinates (reverse geocoding)
      debugPrint('🌍 Getting address from coordinates...');
      await _getAddressFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // Listen to position updates
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) async {
        setState(() {
          _currentPosition = position;
          _locationStatus = 'Location updated';
        });

        // Update address when position changes
        await _getAddressFromCoordinates(position.latitude, position.longitude);
      });

      setState(() {
        _locationStatus = 'Location acquired successfully';
      });
      debugPrint('✅ Location initialization completed successfully');
    } catch (e) {
      debugPrint('❌ Location initialization error: $e');
      setState(() {
        _locationStatus = 'Error getting location: $e';
      });
    }
  }

  /// Initialize battery monitoring
  Future<void> _initializeBattery() async {
    try {
      _batteryLevel = await _battery.batteryLevel;
      _batteryState = await _battery.batteryState;

      // Listen to battery changes
      _battery.onBatteryStateChanged.listen((BatteryState state) {
        setState(() {
          _batteryState = state;
        });
      });

      setState(() {});
    } catch (e) {
      debugPrint('Battery error: $e');
    }
  }

  /// Initialize motion sensors with comprehensive platform detection
  Future<void> _initializeMotionSensors() async {
    try {
      debugPrint('🎯 Starting motion sensors...');

      // Comprehensive platform detection
      if (kIsWeb) {
        debugPrint('🌐 PLATFORM: Running on Web Browser');
        debugPrint('⚠️ Motion sensors are NOT supported on desktop browsers');
        debugPrint(
          '📱 They only work on mobile browsers with HTTPS and user permission',
        );

        // Set a mock message for web users
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              // No actual sensor data available on web
            });
          }
        });

        debugPrint('❌ Skipping sensor initialization on web platform');
        return;
      }

      debugPrint('📱 PLATFORM: Running on native device (Android/iOS)');
      debugPrint('✅ Motion sensors should be available');

      // Only initialize sensors on native platforms
      _accelerometerSubscription = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 200),
      ).listen(
        (AccelerometerEvent event) {
          debugPrint(
            '📱 Accelerometer: x=${event.x.toStringAsFixed(2)}, y=${event.y.toStringAsFixed(2)}, z=${event.z.toStringAsFixed(2)}',
          );
          if (mounted) {
            setState(() {
              _accelerometerData = event;
            });
          }
        },
        onError: (error) {
          debugPrint('❌ Accelerometer error: $error');
          if (mounted) {
            setState(() {
              _accelerometerData = null;
            });
          }
        },
        cancelOnError: false,
      );

      _gyroscopeSubscription = gyroscopeEventStream(
        samplingPeriod: const Duration(milliseconds: 200),
      ).listen(
        (GyroscopeEvent event) {
          debugPrint(
            '🌀 Gyroscope: x=${event.x.toStringAsFixed(2)}, y=${event.y.toStringAsFixed(2)}, z=${event.z.toStringAsFixed(2)}',
          );
          if (mounted) {
            setState(() {
              _gyroscopeData = event;
            });
          }
        },
        onError: (error) {
          debugPrint('❌ Gyroscope error: $error');
          if (mounted) {
            setState(() {
              _gyroscopeData = null;
            });
          }
        },
        cancelOnError: false,
      );

      debugPrint('✅ Native motion sensors initialized successfully');
    } catch (e) {
      debugPrint('❌ Motion sensors initialization error: $e');
    }
  }

  /// Initialize network connectivity monitoring
  Future<void> _initializeConnectivity() async {
    try {
      _connectivityResult = await Connectivity().checkConnectivity();

      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
        List<ConnectivityResult> result,
      ) {
        setState(() {
          _connectivityResult = result;
        });
      });
    } catch (e) {
      debugPrint('Connectivity error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information'),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLocationCard(),
          const SizedBox(height: 16),
          _buildSensorsCard(),
          const SizedBox(height: 16),
          _buildBatteryCard(),
          const SizedBox(height: 16),
          _buildConnectivityCard(),
        ],
      ),
    );
  }

  /// Build GPS location information card with button
  Widget _buildLocationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Text(
                      'GPS Location',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  icon:
                      _isGettingLocation
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.my_location),
                  label: Text(
                    _isGettingLocation ? 'Getting...' : 'Get Location',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Status', _locationStatus),
            if (_currentPosition != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Current Location',
                _locationAddress,
                isMultiline: true,
              ),
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text(
                  'Detailed Coordinates',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                children: [
                  _buildInfoRow(
                    'Latitude',
                    _currentPosition!.latitude.toStringAsFixed(6),
                  ),
                  _buildInfoRow(
                    'Longitude',
                    _currentPosition!.longitude.toStringAsFixed(6),
                  ),
                  _buildInfoRow(
                    'Altitude',
                    '${_currentPosition!.altitude.toStringAsFixed(2)} m',
                  ),
                  _buildInfoRow(
                    'Accuracy',
                    '${_currentPosition!.accuracy.toStringAsFixed(2)} m',
                  ),
                  _buildInfoRow(
                    'Speed',
                    '${_currentPosition!.speed.toStringAsFixed(2)} m/s',
                  ),
                  _buildInfoRow(
                    'Timestamp',
                    _currentPosition!.timestamp.toString(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build battery information card
  Widget _buildBatteryCard() {
    Color batteryColor = Colors.green;
    IconData batteryIcon = Icons.battery_full;

    if (_batteryLevel < 20) {
      batteryColor = Colors.red;
      batteryIcon = Icons.battery_alert;
    } else if (_batteryLevel < 50) {
      batteryColor = Colors.orange;
      batteryIcon = Icons.battery_3_bar;
    }

    String batteryStateText = _batteryState.toString().split('.').last;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(batteryIcon, color: batteryColor),
                const SizedBox(width: 8),
                Text(
                  'Battery Status',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _batteryLevel / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$_batteryLevel%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: batteryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('State', batteryStateText),
          ],
        ),
      ),
    );
  }

  /// Build motion sensors card with start/stop button
  Widget _buildSensorsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.vibration, color: Colors.purple[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Motion Sensors',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: kIsWeb ? null : _startSensors,
                  icon: Icon(_sensorsActive ? Icons.stop : Icons.play_arrow),
                  label: Text(
                    kIsWeb
                        ? 'Web Unsupported'
                        : _sensorsActive
                        ? 'Stop Sensors'
                        : 'Start Sensors',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        kIsWeb
                            ? Colors.grey
                            : _sensorsActive
                            ? Colors.red
                            : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Web Platform Warning
            if (kIsWeb) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Chrome Browser Limitation',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '🖥️ Motion sensors are NOT supported on desktop browsers.\n'
                      '📱 They only work on mobile browsers with HTTPS + user permission.\n'
                      '✅ Use mobile app for full sensor functionality.',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            Text(
              'Accelerometer',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            if (kIsWeb) ...[
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Not available on web platform',
                    style: TextStyle(
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ] else if (_accelerometerData != null) ...[
              _buildInfoRow('X-axis', _accelerometerData!.x.toStringAsFixed(3)),
              _buildInfoRow('Y-axis', _accelerometerData!.y.toStringAsFixed(3)),
              _buildInfoRow('Z-axis', _accelerometerData!.z.toStringAsFixed(3)),
            ] else
              const Text('No accelerometer data'),
            const SizedBox(height: 12),
            Text(
              'Gyroscope',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            if (kIsWeb) ...[
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Not available on web platform',
                    style: TextStyle(
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ] else if (_gyroscopeData != null) ...[
              _buildInfoRow('X-axis', _gyroscopeData!.x.toStringAsFixed(3)),
              _buildInfoRow('Y-axis', _gyroscopeData!.y.toStringAsFixed(3)),
              _buildInfoRow('Z-axis', _gyroscopeData!.z.toStringAsFixed(3)),
            ] else
              const Text('No gyroscope data'),
          ],
        ),
      ),
    );
  }

  /// Build network connectivity information card
  Widget _buildConnectivityCard() {
    Color connectivityColor = Colors.red;
    IconData connectivityIcon = Icons.wifi_off;
    String connectivityText = 'No Connection';

    if (_connectivityResult.contains(ConnectivityResult.wifi)) {
      connectivityColor = Colors.green;
      connectivityIcon = Icons.wifi;
      connectivityText = 'WiFi Connected';
    } else if (_connectivityResult.contains(ConnectivityResult.mobile)) {
      connectivityColor = Colors.blue;
      connectivityIcon = Icons.signal_cellular_4_bar;
      connectivityText = 'Mobile Data Connected';
    } else if (_connectivityResult.contains(ConnectivityResult.ethernet)) {
      connectivityColor = Colors.orange;
      connectivityIcon = Icons.cable;
      connectivityText = 'Ethernet Connected';
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(connectivityIcon, color: connectivityColor),
                const SizedBox(width: 8),
                Text(
                  'Network Connectivity',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Status', connectivityText),
            _buildInfoRow(
              'Connection Types',
              _connectivityResult
                  .map((e) => e.toString().split('.').last)
                  .join(', '),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build information rows
  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child:
          isMultiline
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$label:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      '$label:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
    );
  }
}
