import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service class to handle network connectivity status
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<ConnectivityResult>? _connectivityController;

  /// Stream to listen to connectivity changes
  Stream<ConnectivityResult> get connectivityStream {
    _connectivityController ??=
        StreamController<ConnectivityResult>.broadcast();
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty) {
        _connectivityController!.add(results.first);
      }
    });
    return _connectivityController!.stream;
  }

  /// Check current connectivity status
  Future<ConnectivityResult> checkConnectivity() async {
    try {
      final List<ConnectivityResult> results =
          await _connectivity.checkConnectivity();
      return results.isNotEmpty ? results.first : ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return ConnectivityResult.none;
    }
  }

  /// Check if device is connected to internet
  Future<bool> isConnected() async {
    final result = await checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Get connectivity status as string
  Future<String> getConnectivityStatus() async {
    final result = await checkConnectivity();
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
      default:
        return 'No Connection';
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivityController?.close();
    _connectivityController = null;
  }
}
