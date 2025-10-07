import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Generic API service for all HTTP requests
/// Handles authentication tokens, error responses, and request formatting
class ApiService {
  static const String baseUrl = 'http://13.204.86.61/api/apparel';
  static const String tokenKey = 'auth_token';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Get stored auth token (private)
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(tokenKey);
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  /// Get stored auth token (public)
  Future<String?> getToken() async {
    return await _getToken();
  }

  /// Save auth token
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
      debugPrint('Token saved successfully');
    } catch (e) {
      debugPrint('Error saving token: $e');
      throw Exception('Failed to save authentication token');
    }
  }

  /// Remove auth token
  Future<void> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      debugPrint('Token removed successfully');
    } catch (e) {
      debugPrint('Error removing token: $e');
    }
  }

  /// Get headers with optional authentication
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };

    if (includeAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle API response and errors
  ApiResponse _handleResponse(http.Response response) {
    debugPrint('API Response: ${response.statusCode} - ${response.body}');

    try {
      // Handle HTML error responses (like 404 pages)
      if (response.body.trim().startsWith('<') || response.statusCode == 404) {
        String errorMessage = 'Route not found';
        if (response.statusCode == 404) {
          errorMessage =
              'API endpoint not found (404). Check if Laravel routes are properly configured.';
        }
        return ApiResponse.error(errorMessage, response.statusCode);
      }

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(data);
      } else {
        final message =
            data['message'] ?? data['error'] ?? 'Unknown error occurred';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e) {
      debugPrint('JSON parsing error: $e');
      if (response.statusCode == 404) {
        return ApiResponse.error(
          'API endpoint not found. Check Laravel routes.',
          response.statusCode,
        );
      }
      return ApiResponse.error(
        'Invalid response format: ${response.body}',
        response.statusCode,
      );
    }
  }

  /// Generic GET request
  Future<ApiResponse> get(String endpoint, {bool includeAuth = true}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);

      debugPrint('GET Request: $url');

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('Network error occurred');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      debugPrint('GET request error: $e');
      return ApiResponse.error('Request failed: $e');
    }
  }

  /// Generic POST request
  Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);

      debugPrint('POST Request: $url');
      debugPrint('POST Body: ${jsonEncode(body ?? {})}');

      final response = await http
          .post(url, headers: headers, body: jsonEncode(body ?? {}))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('Network error occurred');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      debugPrint('POST request error: $e');
      return ApiResponse.error('Request failed: $e');
    }
  }

  /// Generic PUT request
  Future<ApiResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);

      debugPrint('PUT Request: $url');

      final response = await http
          .put(url, headers: headers, body: jsonEncode(body ?? {}))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('Network error occurred');
    } catch (e) {
      debugPrint('PUT request error: $e');
      return ApiResponse.error('Request failed: $e');
    }
  }

  /// Generic DELETE request
  Future<ApiResponse> delete(String endpoint, {bool includeAuth = true}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);

      debugPrint('DELETE Request: $url');

      final response = await http
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException {
      return ApiResponse.error('Network error occurred');
    } catch (e) {
      debugPrint('DELETE request error: $e');
      return ApiResponse.error('Request failed: $e');
    }
  }

  /// Test API connectivity
  Future<ApiResponse> testConnection() async {
    try {
      final url = Uri.parse(baseUrl);
      debugPrint('Testing API connection: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      debugPrint('Connection test response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return ApiResponse.error('Cannot connect to API server: $e');
    }
  }

  /// Convert relative image URL to full URL
  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/300x300.png?text=No+Image';
    }

    if (imagePath.startsWith('http')) {
      return imagePath; // Already full URL
    }

    // Convert relative path to full URL
    return 'http://13.204.86.61/storage/$imagePath';
  }
}

/// API Response wrapper class
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final int? statusCode;

  ApiResponse._({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(dynamic data) {
    return ApiResponse._(success: true, data: data);
  }

  factory ApiResponse.error(String error, [int? statusCode]) {
    return ApiResponse._(success: false, error: error, statusCode: statusCode);
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, data: $data, error: $error, statusCode: $statusCode}';
  }
}
