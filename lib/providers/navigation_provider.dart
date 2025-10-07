import 'package:flutter/material.dart';

/// Provider class to manage app navigation state
/// Handles bottom navigation, screen transitions, and navigation history
class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  final List<int> _navigationHistory = [0];
  bool _canGoBack = false;

  // Getters for accessing navigation state
  int get currentIndex => _currentIndex;
  bool get canGoBack => _canGoBack;
  List<int> get navigationHistory => List.unmodifiable(_navigationHistory);

  /// Set current navigation index
  /// Updates bottom navigation and manages navigation history
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;

      // Update navigation history
      if (_navigationHistory.isEmpty || _navigationHistory.last != index) {
        _navigationHistory.add(index);

        // Keep history manageable (max 10 items)
        if (_navigationHistory.length > 10) {
          _navigationHistory.removeAt(0);
        }
      }

      _updateCanGoBack();
      notifyListeners();
    }
  }

  /// Navigate to specific screen by index
  void navigateToIndex(int index) {
    setCurrentIndex(index);
  }

  /// Navigate to home screen
  void navigateToHome() {
    setCurrentIndex(0);
  }

  /// Navigate to categories screen
  void navigateToCategories() {
    setCurrentIndex(1);
  }

  /// Navigate to cart screen
  void navigateToCart() {
    setCurrentIndex(2);
  }

  /// Navigate to profile screen
  void navigateToProfile() {
    setCurrentIndex(3);
  }

  /// Go back to previous screen in navigation history
  bool goBack() {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      _currentIndex = _navigationHistory.last;
      _updateCanGoBack();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Clear navigation history
  void clearHistory() {
    _navigationHistory.clear();
    _navigationHistory.add(_currentIndex);
    _updateCanGoBack();
    notifyListeners();
  }

  /// Reset navigation to home
  void resetToHome() {
    _currentIndex = 0;
    _navigationHistory.clear();
    _navigationHistory.add(0);
    _updateCanGoBack();
    notifyListeners();
  }

  /// Update can go back status
  void _updateCanGoBack() {
    _canGoBack = _navigationHistory.length > 1;
  }

  /// Get screen name by index
  String getScreenName(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Categories';
      case 2:
        return 'Cart';
      case 3:
        return 'Profile';
      default:
        return 'Unknown';
    }
  }

  /// Get current screen name
  String get currentScreenName => getScreenName(_currentIndex);

  /// Check if currently on specific screen
  bool isOnScreen(int index) => _currentIndex == index;
  bool get isOnHome => isOnScreen(0);
  bool get isOnCategories => isOnScreen(1);
  bool get isOnCart => isOnScreen(2);
  bool get isOnProfile => isOnScreen(3);
}
