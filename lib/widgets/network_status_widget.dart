import 'package:flutter/material.dart';
import '../utils/network_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network status widget that shows connectivity information
/// Displays offline message when network is unavailable
class NetworkStatusWidget extends StatefulWidget {
  final Widget child;

  const NetworkStatusWidget({super.key, required this.child});

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget>
    with TickerProviderStateMixin {
  final NetworkService _networkService = NetworkService();
  bool _isConnected = true;
  bool _showOfflineMessage = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _checkInitialConnectivity();
    _listenToConnectivityChanges();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkInitialConnectivity() async {
    final isConnected = await _networkService.isConnected();
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
        if (!isConnected) {
          _showOfflineMessage = true;
          _animationController.forward();
        }
      });
    }
  }

  void _listenToConnectivityChanges() {
    _networkService.connectivityStream.listen((result) {
      final isConnected = result != ConnectivityResult.none;

      if (mounted && _isConnected != isConnected) {
        setState(() {
          _isConnected = isConnected;
        });

        if (!isConnected) {
          // Show offline message
          _showOfflineMessage = true;
          _animationController.forward();
        } else {
          // Hide offline message after a delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _animationController.reverse().then((_) {
                if (mounted) {
                  setState(() {
                    _showOfflineMessage = false;
                  });
                }
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter, // Using non-directional alignment
      children: [
        widget.child,

        // Offline message overlay
        if (_showOfflineMessage)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: _isConnected ? Colors.green : Colors.red,
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.wifi : Icons.wifi_off,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isConnected
                                ? 'Connection restored'
                                : 'No internet connection - Some features may not work',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (!_isConnected)
                          TextButton(
                            onPressed: () {
                              _checkInitialConnectivity();
                            },
                            child: const Text(
                              'Retry',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
