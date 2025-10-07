import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

/// Provider class to manage authentication state throughout the app
/// Handles login, registration, logout via Laravel API with token management
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  final ApiService _apiService = ApiService();

  // Getters for accessing authentication state
  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _user?.email ?? '';
  String get userName => _user?.name ?? '';
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Clear error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initialize authentication state from SharedPreferences
  /// Checks for stored token and validates with Laravel API
  Future<void> initializeAuthState() async {
    try {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      final token = await _apiService.getToken();
      if (token != null) {
        // Validate token with API by fetching user profile
        final response = await _apiService.get('/user');
        if (response.success && response.data != null) {
          _user = User.fromJson(response.data);
          _isLoggedIn = true;
          debugPrint('Auth initialized: user=${_user?.name} (${_user?.email})');
        } else {
          // Token invalid, clear it
          await _apiService.removeToken();
          _isLoggedIn = false;
          _user = null;
        }
      } else {
        _isLoggedIn = false;
        _user = null;
      }

      _isInitialized = true;
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (error) {
      debugPrint('Auth initialization error: $error');
      _isInitialized = true;
      _isLoading = false;
      _isLoggedIn = false;
      _user = null;
      await _apiService.removeToken();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Login user with email and password via Laravel API
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.post(
        '/login',
        body: {'email': email, 'password': password},
      );

      if (response.success && response.data != null) {
        // Save token from response
        final token = response.data['token'];
        if (token != null) {
          await _apiService.saveToken(token);
        }

        // Set user data - handle case where user is just email string
        final userData = response.data['user'];
        if (userData is String) {
          // Laravel API returns user as email string, create minimal User object
          _user = User(
            id: '',
            name: '',
            email: userData,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        } else if (userData is Map<String, dynamic>) {
          // User data is a proper object
          _user = User.fromJson(userData);
        } else {
          // Fallback: try using the entire response data
          _user = User.fromJson(response.data);
        }

        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      debugPrint('Login error: $error');
      _errorMessage = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register new user via Laravel API
  Future<bool> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.post(
        '/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.success && response.data != null) {
        // Save token from response
        final token = response.data['token'];
        if (token != null) {
          await _apiService.saveToken(token);
        }

        // Set user data
        final userData = response.data['user'] ?? response.data;
        _user = User.fromJson(userData);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      debugPrint('Registration error: $error');
      _errorMessage = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user and clear all stored authentication data
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Call logout API endpoint
      await _apiService.post('/logout', body: {});
    } catch (error) {
      debugPrint('Logout API error: $error');
      // Continue with local logout even if API call fails
    } finally {
      // Clear local state regardless of API result
      _user = null;
      _isLoggedIn = false;
      _errorMessage = null;
      await _apiService.removeToken();

      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile information via Laravel API
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (city != null) updateData['city'] = city;
      if (state != null) updateData['state'] = state;
      if (country != null) updateData['country'] = country;
      if (zipCode != null) updateData['zip_code'] = zipCode;

      final response = await _apiService.put('/user', body: updateData);

      if (response.success && response.data != null) {
        _user = User.fromJson(response.data);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error ?? 'Profile update failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      debugPrint('Profile update error: $error');
      _errorMessage = 'Profile update failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change user password via Laravel API
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.put(
        '/user/password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error ?? 'Password change failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      debugPrint('Password change error: $error');
      _errorMessage = 'Password change failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh user data from API
  Future<bool> refreshUser() async {
    try {
      if (!_isLoggedIn) return false;

      final response = await _apiService.get('/user');
      if (response.success && response.data != null) {
        _user = User.fromJson(response.data);
        notifyListeners();
        return true;
      }
      return false;
    } catch (error) {
      debugPrint('Refresh user error: $error');
      return false;
    }
  }

  /// Set demo user for CORS testing (bypasses API calls)
  Future<void> setDemoUser() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create demo user without API call
      _user = User(
        id: 'demo_user_001',
        name: 'Demo User',
        email: 'it22232922@my.sliit.lk',
        phone: '+94 71 244 4528',
        address: '123 Demo Street',
        city: 'Colombo',
        state: 'Western',
        country: 'Sri Lanka',
        zipCode: '10100',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: {'theme': 'light', 'language': 'en'},
      );

      _isLoggedIn = true;
      _isLoading = false;
      debugPrint('Demo user set: ${_user?.name} (${_user?.email})');
      notifyListeners();
    } catch (error) {
      debugPrint('Demo login error: $error');
      _errorMessage = 'Demo login failed';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
