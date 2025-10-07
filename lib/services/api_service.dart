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
        debugPrint('API Error Response: ${response.body}');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Error Data: $data');
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

  // ==========================================
  // CART API METHODS
  // ==========================================

  /// Get user's cart items
  Future<ApiResponse> getCart() async {
    return await get('/cart');
  }

  /// Get cart items count
  Future<ApiResponse> getCartCount() async {
    return await get('/cart/count');
  }

  /// Add item to cart with proper field structure
  Future<ApiResponse> addToCart({
    required String productId,
    required int quantity,
  }) async {
    debugPrint(
      '🛒 Adding to cart - Product ID: $productId, Quantity: $quantity',
    );

    return await post(
      '/cart/add',
      body: {
        'product_id': productId,
        'quantity': quantity,
        // Remove the cart_item_id as it might be causing confusion
      },
    );
  }

  /// Update cart item quantity using cart item ID
  Future<ApiResponse> updateCartItem({
    required String cartItemId, // Changed from productId to cartItemId
    required int quantity,
  }) async {
    debugPrint(
      '🔄 Updating cart item - Cart Item ID: $cartItemId, Quantity: $quantity',
    );

    return await put(
      '/cart/update/$cartItemId', // Use cart item ID in URL
      body: {'quantity': quantity},
    );
  }

  /// Remove item from cart using cart item ID
  Future<ApiResponse> removeFromCart(String cartItemId) async {
    return await delete('/cart/remove/$cartItemId');
  }

  /// Clear entire cart
  Future<ApiResponse> clearCart() async {
    return await delete('/cart/clear');
  }

  // ==========================================
  // ORDER API METHODS
  // ==========================================

  /// Create new order (checkout)
  Future<ApiResponse> checkout({
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    // Parse the address string into components for the API
    final addressParts = shippingAddress.split(', ');
    final shippingAddressData = {
      'street': addressParts.isNotEmpty ? addressParts[0] : shippingAddress,
      'city': addressParts.length > 1 ? addressParts[1] : '',
      'state': addressParts.length > 2 ? addressParts[2].split(' ')[0] : '',
      'postal_code':
          addressParts.length > 2 && addressParts[2].split(' ').length > 1
              ? addressParts[2].split(' ')[1]
              : '',
      'country': 'Sri Lanka', // Default country
    };

    return await post(
      '/checkout',
      body: {
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'shipping_address': shippingAddressData,
        'payment_method': paymentMethod,
      },
    );
  }

  /// Get user's order history
  Future<ApiResponse> getOrders() async {
    return await get('/orders');
  }

  /// Get specific order details
  Future<ApiResponse> getOrderById(String orderId) async {
    return await get('/orders/$orderId');
  }

  /// Cancel an order
  Future<ApiResponse> cancelOrder(String orderId) async {
    return await put('/orders/$orderId/cancel');
  }

  /// Track order by order number
  Future<ApiResponse> trackOrder(String orderNumber) async {
    return await get('/track/$orderNumber');
  }

  // ==========================================
  // PROFILE API METHODS
  // ==========================================

  /// Get user profile information
  Future<ApiResponse> getProfile() async {
    debugPrint('🔄 Getting user profile from /profile endpoint...');
    final response = await get('/profile');

    // If /profile fails, try /user endpoint as fallback
    if (!response.success && response.statusCode == 404) {
      debugPrint('⚠️ /profile endpoint not found, trying /user...');
      return await get('/user');
    }

    return response;
  }

  /// Update user profile information
  Future<ApiResponse> updateProfile({
    required String fullName,
    required String phone,
    required String streetAddress,
    required String city,
    required String postalCode,
  }) async {
    return await put(
      '/profile',
      body: {
        'full_name': fullName,
        'phone': phone,
        'street_address': streetAddress,
        'city': city,
        'postal_code': postalCode,
      },
    );
  }

  /// Upload profile picture
  Future<ApiResponse> uploadProfilePicture(String imagePath) async {
    // This is a placeholder for profile picture upload
    // In a real implementation, you would use multipart/form-data
    return await post(
      '/profile/picture',
      body: {
        'image_path': imagePath,
        'message':
            'Profile picture upload feature - implementation depends on backend requirements',
      },
    );
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
