import 'dart:async';
import 'package:battery_plus/battery_plus.dart';

/// Service class to handle battery status and information
class BatteryService {
  static final BatteryService _instance = BatteryService._internal();
  factory BatteryService() => _instance;
  BatteryService._internal();

  final Battery _battery = Battery();
  StreamController<BatteryState>? _batteryStateController;
  StreamController<int>? _batteryLevelController;

  /// Stream to listen to battery state changes
  Stream<BatteryState> get batteryStateStream {
    _batteryStateController ??= StreamController<BatteryState>.broadcast();
    _battery.onBatteryStateChanged.listen((BatteryState state) {
      _batteryStateController!.add(state);
    });
    return _batteryStateController!.stream;
  }

  /// Get current battery level (0-100)
  Future<int> getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (e) {
      print('Error getting battery level: $e');
      return -1;
    }
  }

  /// Get current battery state
  Future<BatteryState> getBatteryState() async {
    try {
      return await _battery.batteryState;
    } catch (e) {
      print('Error getting battery state: $e');
      return BatteryState.unknown;
    }
  }

  /// Check if battery is charging
  Future<bool> isCharging() async {
    final state = await getBatteryState();
    return state == BatteryState.charging;
  }

  /// Check if battery is full
  Future<bool> isFull() async {
    final state = await getBatteryState();
    return state == BatteryState.full;
  }

  /// Check if battery is discharging
  Future<bool> isDischarging() async {
    final state = await getBatteryState();
    return state == BatteryState.discharging;
  }

  /// Get battery state as string
  Future<String> getBatteryStateString() async {
    final state = await getBatteryState();
    switch (state) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      case BatteryState.unknown:
      default:
        return 'Unknown';
    }
  }

  /// Get battery level with state information
  Future<Map<String, dynamic>> getBatteryInfo() async {
    final level = await getBatteryLevel();
    final state = await getBatteryState();
    final stateString = await getBatteryStateString();

    return {
      'level': level,
      'state': state,
      'stateString': stateString,
      'isCharging': state == BatteryState.charging,
      'isFull': state == BatteryState.full,
      'isDischarging': state == BatteryState.discharging,
      'isLowBattery': level < 20 && level > 0,
      'isCriticalBattery': level < 10 && level > 0,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Get battery health category
  String getBatteryHealthCategory(int level) {
    if (level < 0) return 'Unknown';
    if (level <= 5) return 'Critical';
    if (level <= 15) return 'Very Low';
    if (level <= 30) return 'Low';
    if (level <= 60) return 'Medium';
    if (level <= 80) return 'Good';
    return 'Excellent';
  }

  /// Get estimated time remaining (this is a simple estimation)
  String getEstimatedTimeRemaining(int level, BatteryState state) {
    if (level < 0) return 'Unknown';

    if (state == BatteryState.charging) {
      if (level >= 90) return '< 30 min';
      if (level >= 70) return '1-2 hours';
      if (level >= 50) return '2-3 hours';
      if (level >= 30) return '3-4 hours';
      return '4+ hours';
    } else if (state == BatteryState.discharging) {
      if (level <= 10) return '< 1 hour';
      if (level <= 30) return '2-4 hours';
      if (level <= 50) return '4-8 hours';
      if (level <= 70) return '8-12 hours';
      return '12+ hours';
    }

    return 'Unknown';
  }

  /// Monitor battery level changes with custom interval
  Stream<int> monitorBatteryLevel({
    Duration interval = const Duration(seconds: 30),
  }) async* {
    while (true) {
      yield await getBatteryLevel();
      await Future.delayed(interval);
    }
  }

  /// Get battery icon based on level and state
  String getBatteryIcon(int level, BatteryState state) {
    if (state == BatteryState.charging) {
      return '🔋⚡'; // Charging icon
    }

    if (level <= 10) return '🪫'; // Very low battery
    if (level <= 25) return '🔋'; // Low battery
    if (level <= 50) return '🔋'; // Medium battery
    if (level <= 75) return '🔋'; // Good battery
    return '🔋'; // Full battery
  }

  /// Format battery information for display
  String formatBatteryInfo(Map<String, dynamic> batteryInfo) {
    final level = batteryInfo['level'] as int;
    final stateString = batteryInfo['stateString'] as String;
    final icon = getBatteryIcon(level, batteryInfo['state'] as BatteryState);

    return '$icon $level% - $stateString';
  }

  /// Check if battery level is critical and needs attention
  bool isBatteryCritical(int level) {
    return level <= 10 && level > 0;
  }

  /// Check if battery should trigger low battery warning
  bool shouldShowLowBatteryWarning(int level) {
    return level <= 20 && level > 0;
  }

  /// Dispose resources
  void dispose() {
    _batteryStateController?.close();
    _batteryStateController = null;
    _batteryLevelController?.close();
    _batteryLevelController = null;
  }
}
