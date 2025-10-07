import 'package:flutter/material.dart';
import '../models/product.dart';

/// Provider class to manage shopping cart state
/// Handles cart items, quantities, total calculations, and cart operations
class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  // Getters for accessing cart state
  Map<String, CartItem> get items => {..._items};
  List<CartItem> get cartItems => _items.values.toList();
  int get itemCount => _items.length;

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

  /// Add product to cart or increase quantity if already exists
  void addItem(Product product, {int quantity = 1}) {
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
    notifyListeners();
  }

  /// Remove single item quantity or remove product entirely if quantity becomes 0
  void removeItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      // Decrease quantity
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      // Remove item completely
      _items.remove(productId);
    }
    notifyListeners();
  }

  /// Remove product completely from cart regardless of quantity
  void removeProductCompletely(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// Update quantity of specific product in cart
  void updateQuantity(String productId, int newQuantity) {
    if (!_items.containsKey(productId)) return;

    if (newQuantity <= 0) {
      _items.remove(productId);
    } else {
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
    }
    notifyListeners();
  }

  /// Clear entire cart
  void clearCart() {
    _items.clear();
    notifyListeners();
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
