# Device Capability Services

This directory contains comprehensive Flutter services for accessing device capabilities including network connectivity, geolocation, camera, motion sensors, and battery status.

## 📁 Folder Structure

```
lib/utils/
├── device_services.dart          # Export file for easy importing
├── network_service.dart           # Network connectivity service
├── geolocation_service.dart       # GPS location service
├── camera_service.dart            # Camera and image picker service
├── accelerometer_service.dart     # Motion sensors service
└── battery_service.dart           # Battery status service
```

## 📦 Dependencies Added

The following packages have been added to `pubspec.yaml`:

```yaml
dependencies:
  # Device capability services
  geolocator: ^12.0.0              # GPS location
  image_picker: ^1.1.2             # Camera and image picking
  sensors_plus: ^6.0.1             # Motion sensors
  battery_plus: ^6.0.2             # Battery status
  connectivity_plus: ^6.0.5        # Network connectivity
  permission_handler: ^11.3.1      # Permissions handling
  
  # Optional additional sensors
  light: ^4.0.0                    # Ambient light sensor
  proximity_sensor: ^1.0.2         # Proximity sensor
```

## 🚀 Usage Examples

### Import Services

```dart
// Import all services at once
import '../utils/device_services.dart';

// Or import individual services
import '../utils/network_service.dart';
import '../utils/geolocation_service.dart';
import '../utils/camera_service.dart';
import '../utils/accelerometer_service.dart';
import '../utils/battery_service.dart';
```

### Network Service

```dart
final networkService = NetworkService();

// Check current connectivity
final isConnected = await networkService.isConnected();
final status = await networkService.getConnectivityStatus();

// Listen to connectivity changes
networkService.connectivityStream.listen((result) {
  print('Connectivity changed: $result');
});
```

### Geolocation Service

```dart
final geoService = GeolocationService();

// Get current position
final position = await geoService.getCurrentPosition();
if (position != null) {
  print('Lat: ${position.latitude}, Lng: ${position.longitude}');
}

// Listen to position changes
geoService.getPositionStream().listen((position) {
  print('Position updated: ${geoService.formatPosition(position)}');
});
```

### Camera Service

```dart
final cameraService = CameraService();

// Take a photo
final photo = await cameraService.takePhoto(imageQuality: 80);
if (photo != null) {
  // Use the photo file
  Image.file(photo);
}

// Pick from gallery
final image = await cameraService.pickImageFromGallery();

// Pick multiple images
final images = await cameraService.pickMultipleImages();
```

### Accelerometer Service

```dart
final accelService = AccelerometerService();

// Start listening to sensors
accelService.startAllSensors();

// Listen to accelerometer data
accelService.accelerometerStream.listen((event) {
  print('Accelerometer: ${accelService.formatSensorData(event)}');
  
  // Detect shake
  if (accelService.detectShake(event)) {
    print('Device shaken!');
  }
});

// Listen to gyroscope data
accelService.gyroscopeStream.listen((event) {
  print('Gyroscope: ${accelService.formatSensorData(event)}');
});

// Stop sensors when done
accelService.stopAllSensors();
```

### Battery Service

```dart
final batteryService = BatteryService();

// Get battery info
final batteryInfo = await batteryService.getBatteryInfo();
print('Battery: ${batteryService.formatBatteryInfo(batteryInfo)}');

// Check battery level
final level = await batteryService.getBatteryLevel();
final isCharging = await batteryService.isCharging();

// Listen to battery changes
batteryService.batteryStateStream.listen((state) {
  print('Battery state changed: $state');
});
```

## 🔧 Complete Usage in a Widget

```dart
class MyDeviceScreen extends StatefulWidget {
  @override
  _MyDeviceScreenState createState() => _MyDeviceScreenState();
}

class _MyDeviceScreenState extends State<MyDeviceScreen> {
  final networkService = NetworkService();
  final geoService = GeolocationService();
  final cameraService = CameraService();
  final accelService = AccelerometerService();
  final batteryService = BatteryService();
  
  String networkStatus = 'Unknown';
  String location = 'Unknown';
  File? capturedImage;
  String batteryInfo = 'Unknown';
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  void _initializeServices() async {
    // Check network
    networkStatus = await networkService.getConnectivityStatus();
    
    // Get location
    final position = await geoService.getCurrentPosition();
    if (position != null) {
      location = geoService.formatPosition(position);
    }
    
    // Get battery info
    final battery = await batteryService.getBatteryInfo();
    batteryInfo = batteryService.formatBatteryInfo(battery);
    
    setState(() {});
  }
  
  void _takePhoto() async {
    final image = await cameraService.takePhoto();
    setState(() {
      capturedImage = image;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device Capabilities')),
      body: Column(
        children: [
          Text('Network: $networkStatus'),
          Text('Location: $location'),
          Text('Battery: $batteryInfo'),
          if (capturedImage != null) Image.file(capturedImage!),
          ElevatedButton(
            onPressed: _takePhoto,
            child: Text('Take Photo'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    accelService.dispose();
    networkService.dispose();
    batteryService.dispose();
    super.dispose();
  }
}
```

## 📱 Demo Screen

A complete demonstration screen is available at:
`lib/screens/device_capabilities_demo.dart`

To add it to your app navigation:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => DeviceCapabilitiesDemo()),
);
```

## ⚙️ Android Permissions

Add these permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## 🍎 iOS Permissions

Add these to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to provide location-based services.</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images.</string>
```

## 🛠️ Best Practices

1. **Always dispose** services in your widget's `dispose()` method
2. **Handle permissions** gracefully with user-friendly messages
3. **Check service availability** before using (location services, etc.)
4. **Use try-catch blocks** for error handling
5. **Listen to streams** only when needed to save battery
6. **Stop sensor listening** when not needed

## 🔍 Error Handling

All services include comprehensive error handling:

- **Network**: Handles connectivity check failures
- **Location**: Manages permission denials and service unavailability
- **Camera**: Handles permission denials and camera unavailability
- **Sensors**: Manages sensor unavailability
- **Battery**: Handles platform-specific battery API issues

## 📋 Features Included

### NetworkService
- ✅ Real-time connectivity monitoring
- ✅ Connection type detection (WiFi, Mobile, etc.)
- ✅ Connection status checking

### GeolocationService
- ✅ Current position with accuracy settings
- ✅ Real-time position tracking
- ✅ Distance and bearing calculations
- ✅ Permission handling
- ✅ Settings navigation

### CameraService
- ✅ Take photos with quality settings
- ✅ Pick from gallery
- ✅ Multiple image selection
- ✅ Video recording and picking
- ✅ Permission handling
- ✅ File size utilities

### AccelerometerService
- ✅ Accelerometer data streaming
- ✅ Gyroscope data streaming
- ✅ User accelerometer (without gravity)
- ✅ Magnetometer data
- ✅ Shake detection
- ✅ Device orientation detection
- ✅ Motion data analysis

### BatteryService
- ✅ Battery level monitoring
- ✅ Charging state detection
- ✅ Battery health categories
- ✅ Time remaining estimation
- ✅ Low battery warnings
- ✅ Real-time battery changes

## 🚀 Getting Started

1. Ensure all dependencies are installed: `flutter pub get`
2. Add required permissions to Android and iOS
3. Import the services you need
4. Check the demo screen for usage examples
5. Always handle permissions and errors gracefully

## 📞 Support

Each service is designed to be:
- **Modular**: Use only what you need
- **Robust**: Comprehensive error handling
- **Efficient**: Proper resource management
- **Well-documented**: Clear usage examples