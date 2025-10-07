import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_profile.dart';

/// Provider class to manage user profile state and operations
/// Handles profile data fetching, updating, and form management
class ProfileProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _isUpdating = false;

  // Getters
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  bool get hasProfile => _userProfile != null;

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set updating state and notify listeners
  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Fetch user profile from backend
  Future<void> fetchProfile() async {
    _setLoading(true);
    _error = null;

    try {
      debugPrint('🔄 Fetching user profile...');

      // Check if user is authenticated first
      final token = await _apiService.getToken();
      if (token == null) {
        _error = 'User not authenticated - no token found';
        debugPrint('❌ $_error');
        return;
      }

      debugPrint('🔑 Token found, making API call...');
      final response = await _apiService.getProfile();

      debugPrint(
        '📡 Profile API Response: ${response.success ? 'SUCCESS' : 'FAILED'}',
      );
      debugPrint('📊 Response data: ${response.data}');
      debugPrint('🚨 Response error: ${response.error}');

      if (response.success && response.data != null) {
        _userProfile = UserProfile.fromJson(response.data);
        debugPrint('✅ Profile fetched successfully: ${_userProfile?.fullName}');
        debugPrint('📧 Email: ${_userProfile?.email}');
        debugPrint('📱 Phone: ${_userProfile?.phone}');
      } else {
        _error = response.error ?? 'Failed to fetch profile';
        debugPrint('❌ Failed to fetch profile: $_error');
        debugPrint('🔍 API Status Code: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Error fetching profile: $e';
      debugPrint('❌ Error fetching profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String streetAddress,
    required String city,
    required String postalCode,
  }) async {
    _setUpdating(true);
    _error = null;

    try {
      debugPrint('🔄 Updating user profile...');
      final response = await _apiService.updateProfile(
        fullName: fullName,
        phone: phone,
        streetAddress: streetAddress,
        city: city,
        postalCode: postalCode,
      );

      if (response.success) {
        // Update local profile data
        if (_userProfile != null) {
          _userProfile = _userProfile!.copyWith(
            fullName: fullName,
            phone: phone,
            streetAddress: streetAddress,
            city: city,
            postalCode: postalCode,
          );
        }
        debugPrint('✅ Profile updated successfully');
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to update profile';
        debugPrint('❌ Failed to update profile: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Error updating profile: $e';
      debugPrint('❌ Error updating profile: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// Initialize profile (called when app starts or user logs in)
  Future<void> initializeProfile() async {
    await fetchProfile();
  }

  /// Clear profile data (called when user logs out)
  void clearProfile() {
    _userProfile = null;
    _error = null;
    _isLoading = false;
    _isUpdating = false;
    notifyListeners();
  }

  /// Get profile form data for pre-filling forms
  Map<String, String> getFormData() {
    if (_userProfile == null) {
      return {
        'fullName': '',
        'phone': '',
        'streetAddress': '',
        'city': '',
        'postalCode': '',
      };
    }

    return {
      'fullName': _userProfile!.fullName,
      'phone': _userProfile!.phone,
      'streetAddress': _userProfile!.streetAddress,
      'city': _userProfile!.city,
      'postalCode': _userProfile!.postalCode,
    };
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    if (_userProfile == null) return false;

    return _userProfile!.fullName.isNotEmpty &&
        _userProfile!.phone.isNotEmpty &&
        _userProfile!.streetAddress.isNotEmpty &&
        _userProfile!.city.isNotEmpty &&
        _userProfile!.postalCode.isNotEmpty;
  }
}
