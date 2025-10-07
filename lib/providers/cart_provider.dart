import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

/// Provider class to manage shopping cart state with backend synchronization
/// Handles cart items, quantities, total calculations, and cart operations
class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;

  // Getters for accessing cart state
  Map<String, CartItem> get items => {..._items};
  List<CartItem> get cartItems => _items.values.toList();
  int get itemCount => _items.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Calculate total quantity of all items in cart
  int get totalQuantity {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  /// Calculate total price of all items in cart
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  /// Check if cart is empty
  bool get isEmpty => _items.isEmpty;

  /// Check if a specific product is in cart
  bool isInCart(String productId) {
    return _items.containsKey(productId);
  }

  /// Get quantity of specific product in cart
  int getQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }

  /// Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Load cart from backend
  Future<void> loadCartFromBackend() async {
    _setLoading(true);
    _error = null;

    try {
      debugPrint('🔄 Loading cart from backend...');
      final response = await _apiService.getCart();

      debugPrint('📊 Cart API Response:');
      debugPrint('  - Success: ${response.success}');
      debugPrint('  - Error: ${response.error}');
      debugPrint('  - Data: ${response.data}');

      if (response.success) {
        _items.clear();

        // Parse cart items from backend response
        final cartData = response.data;
        debugPrint('🔍 Parsing cart data type: ${cartData.runtimeType}');
        debugPrint(
          '🔍 Cart data keys: ${cartData is Map ? cartData.keys.join(', ') : 'Not a Map'}',
        );

        if (cartData != null) {
          List? items;

          // The API response structure is: {"success": true, "data": {"items": [...], "summary": {...}}}
          // cartData contains the full response, so we need to access cartData['data']['items']
          if (cartData is Map) {
            debugPrint('🔍 Parsing cart data: ${cartData.keys.join(', ')}');

            // Check if cartData has the 'data' key (full API response)
            if (cartData['data'] != null && cartData['data'] is Map) {
              final dataSection = cartData['data'] as Map;
              debugPrint(
                '🔍 Data section keys: ${dataSection.keys.join(', ')}',
              );

              if (dataSection['items'] != null &&
                  dataSection['items'] is List) {
                items = dataSection['items'] as List;
                debugPrint('📦 Found cart items: ${items.length} items');
              }
            }
            // Fallback: direct items access (if cartData is already the data section)
            else if (cartData['items'] != null && cartData['items'] is List) {
              items = cartData['items'] as List;
              debugPrint('📦 Found direct cart items: ${items.length} items');
            }
          } else if (cartData is List) {
            // Fallback: cartData is directly an array
            items = cartData;
            debugPrint('📦 Cart data is direct list: ${items.length} items');
          }

          if (items != null && items.isNotEmpty) {
            debugPrint('🛒 Processing ${items.length} cart items:');

            for (var i = 0; i < items.length; i++) {
              final item = items[i];
              debugPrint('  Item $i: $item');

              // Handle nested product structure from API response
              String productId = '';
              String productName = '';
              double productPrice = 0.0;
              String productImage = '';
              int quantity = 0;

              if (item['product'] != null) {
                // API response format: {"id": 38, "quantity": 1, "product": {...}}
                final product = item['product'];
                productId = product['id']?.toString() ?? '';
                productName = product['name']?.toString() ?? '';
                productPrice =
                    double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;
                productImage = product['image']?.toString() ?? '';
                quantity =
                    int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
              } else {
                // Fallback for direct item format
                productId =
                    item['product_id']?.toString() ??
                    item['id']?.toString() ??
                    '';
                productName =
                    item['product_name']?.toString() ??
                    item['name']?.toString() ??
                    '';
                productPrice =
                    double.tryParse(
                      item['unit_price']?.toString() ??
                          item['price']?.toString() ??
                          '0',
                    ) ??
                    0.0;
                productImage =
                    item['product_image']?.toString() ??
                    item['image']?.toString() ??
                    '';
                quantity =
                    int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
              }

              final cartItem = CartItem(
                id: productId,
                title: productName,
                price: productPrice,
                quantity: quantity,
                imageUrl: productImage,
              );

              debugPrint(
                '  Processed: ${cartItem.title} (${cartItem.quantity}x @ Rs.${cartItem.price})',
              );
              _items[cartItem.id] = cartItem;
            }
          } else {
            debugPrint('📭 No cart items found in response');
          }
        }
        debugPrint('✅ Cart loaded from backend: ${_items.length} items');
      } else {
        _error = response.error ?? 'Failed to load cart';
        debugPrint('❌ Failed to load cart: ${response.error}');
      }
    } catch (e) {
      _error = 'Error loading cart: $e';
      debugPrint('❌ Error loading cart: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add product to cart or increase quantity if already exists
  Future<void> addItem(Product product, {int quantity = 1}) async {
    _setLoading(true);
    _error = null;

    try {
      // Always update local state first for immediate UI feedback
      if (_items.containsKey(product.id)) {
        // Product already in cart, increase quantity
        _items.update(
          product.id,
          (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            price: existingCartItem.price,
            quantity: existingCartItem.quantity + quantity,
            imageUrl: existingCartItem.imageUrl,
          ),
        );
      } else {
        // New product, add to cart
        _items.putIfAbsent(
          product.id,
          () => CartItem(
            id: product.id,
            title: product.name,
            price: product.price,
            quantity: quantity,
            imageUrl: product.image,
          ),
        );
      }

      debugPrint('✅ Item added to local cart: ${product.name} x$quantity');

      // Try to sync with backend if user is logged in
      try {
        final response = await _apiService.addToCart(
          productId: product.id,
          quantity: quantity,
        );

        if (response.success) {
          debugPrint('✅ Cart synced with backend successfully');
        } else {
          debugPrint(
            '⚠️ Backend sync failed, cart works offline: ${response.error}',
          );
        }
      } catch (e) {
        debugPrint('⚠️ Backend sync failed, cart works offline: $e');
      }
    } catch (e) {
      _error = 'Error adding item to cart: $e';
      debugPrint('❌ Error adding item to cart: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Remove single item quantity or remove product entirely if quantity becomes 0
  Future<void> removeItem(String productId) async {
    if (!_items.containsKey(productId)) return;

    _setLoading(true);
    _error = null;

    try {
      final currentQuantity = _items[productId]!.quantity;

      // Update local state first
      if (currentQuantity > 1) {
        // Decrease quantity locally
        final newQuantity = currentQuantity - 1;
        _items.update(
          productId,
          (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            price: existingCartItem.price,
            quantity: newQuantity,
            imageUrl: existingCartItem.imageUrl,
          ),
        );
        debugPrint('✅ Item quantity decreased locally');

        // Try to sync with backend
        try {
          final response = await _apiService.updateCartItem(
            productId: productId,
            quantity: newQuantity,
          );
          if (response.success) {
            debugPrint('✅ Quantity update synced with backend');
          } else {
            debugPrint(
              '⚠️ Backend sync failed, cart works offline: ${response.error}',
            );
          }
        } catch (e) {
          debugPrint('⚠️ Backend sync failed, cart works offline: $e');
        }
      } else {
        // Remove item completely from local state
        _items.remove(productId);
        debugPrint('✅ Item removed from local cart');

        // Try to sync with backend
        try {
          final response = await _apiService.removeFromCart(productId);
          if (response.success) {
            debugPrint('✅ Item removal synced with backend');
          } else {
            debugPrint(
              '⚠️ Backend sync failed, cart works offline: ${response.error}',
            );
          }
        } catch (e) {
          debugPrint('⚠️ Backend sync failed, cart works offline: $e');
        }
      }
    } catch (e) {
      _error = 'Error updating cart: $e';
      debugPrint('❌ Error updating cart: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Remove product completely from cart regardless of quantity
  void removeProductCompletely(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// Update quantity of specific product in cart
  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (!_items.containsKey(productId)) return;

    _setLoading(true);
    _error = null;

    try {
      if (newQuantity <= 0) {
        // Remove item locally first
        _items.remove(productId);
        debugPrint('✅ Item removed from local cart (quantity = 0)');

        // Try to sync with backend
        try {
          final response = await _apiService.removeFromCart(productId);
          if (response.success) {
            debugPrint('✅ Item removal synced with backend');
          } else {
            debugPrint(
              '⚠️ Backend sync failed, cart works offline: ${response.error}',
            );
          }
        } catch (e) {
          debugPrint('⚠️ Backend sync failed, cart works offline: $e');
        }
      } else {
        // Update quantity locally first
        _items.update(
          productId,
          (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            price: existingCartItem.price,
            quantity: newQuantity,
            imageUrl: existingCartItem.imageUrl,
          ),
        );
        debugPrint('✅ Item quantity updated locally to $newQuantity');

        // Try to sync with backend
        try {
          final response = await _apiService.updateCartItem(
            productId: productId,
            quantity: newQuantity,
          );
          if (response.success) {
            debugPrint('✅ Quantity update synced with backend');
          } else {
            debugPrint(
              '⚠️ Backend sync failed, cart works offline: ${response.error}',
            );
          }
        } catch (e) {
          debugPrint('⚠️ Backend sync failed, cart works offline: $e');
        }
      }
    } catch (e) {
      _error = 'Error updating quantity: $e';
      debugPrint('❌ Error updating quantity: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    _setLoading(true);
    _error = null;

    try {
      // Clear local cart first
      _items.clear();
      debugPrint('✅ Local cart cleared successfully');

      // Try to sync with backend
      try {
        final response = await _apiService.clearCart();
        if (response.success) {
          debugPrint('✅ Cart clear synced with backend');
        } else {
          debugPrint(
            '⚠️ Backend sync failed, cart works offline: ${response.error}',
          );
        }
      } catch (e) {
        debugPrint('⚠️ Backend sync failed, cart works offline: $e');
      }
    } catch (e) {
      _error = 'Error clearing cart: $e';
      debugPrint('❌ Error clearing cart: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get cart items as formatted list for checkout
  List<Map<String, dynamic>> getCheckoutItems() {
    return _items.values
        .map(
          (item) => {
            'id': item.id,
            'title': item.title,
            'price': item.price,
            'quantity': item.quantity,
            'total': item.price * item.quantity,
          },
        )
        .toList();
  }

  /// Initialize cart (called when user logs in)
  Future<void> initializeCart() async {
    await loadCartFromBackend();
  }

  /// Clear local cart (called when user logs out)
  void clearLocalCart() {
    _items.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

/// Cart item model class
/// Represents individual items stored in the shopping cart
class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  /// Calculate total price for this cart item
  double get totalPrice => price * quantity;

  /// Create copy of cart item with updated values
  CartItem copyWith({
    String? id,
    String? title,
    double? price,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
