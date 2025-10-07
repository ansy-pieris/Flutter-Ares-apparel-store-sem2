import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/checkout_form.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessingOrder = false;
  final ApiService _apiService = ApiService();

  Future<void> _handleFormSubmit(
    BuildContext context,
    String name,
    String address,
    String phone,
    String paymentMethod,
  ) async {
    setState(() {
      _isProcessingOrder = true;
    });

    try {
      debugPrint('🛒 Starting checkout process...');

      // Get cart information for order details
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Check if cart is empty
      if (cartProvider.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Get total amount before clearing cart
      final totalAmount = cartProvider.totalAmount;
      debugPrint('💰 Order total: \$${totalAmount.toStringAsFixed(2)}');
      debugPrint('👤 Customer: $name');
      debugPrint('📱 Phone: $phone');
      debugPrint('📍 Address: $address');
      debugPrint('💳 Payment: $paymentMethod');

      // Check authentication
      final token = await _apiService.getToken();
      if (token == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      debugPrint('🔑 Token found, processing order...');

      // Process order through API
      final response = await _apiService.checkout(
        customerName: name,
        customerPhone: phone,
        shippingAddress: address,
        paymentMethod: paymentMethod,
      );

      debugPrint(
        '📡 Checkout API Response: ${response.success ? 'SUCCESS' : 'FAILED'}',
      );
      debugPrint('📊 Response data: ${response.data}');
      debugPrint('🚨 Response error: ${response.error}');
      debugPrint('🔍 Status Code: ${response.statusCode}');

      if (!response.success) {
        throw Exception(response.error ?? 'Order processing failed');
      }

      debugPrint('✅ Order placed successfully, clearing cart...');

      // Clear the cart after successful order
      await cartProvider.clearCart();

      setState(() {
        _isProcessingOrder = false;
      });

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: 8),
                    Text('Order Placed Successfully!'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thank you, $name!'),
                    const SizedBox(height: 8),
                    Text('Your order has been placed successfully.'),
                    const SizedBox(height: 8),
                    if (response.data != null &&
                        response.data!['order_id'] != null)
                      Text('Order ID: ${response.data!['order_id']}'),
                    if (response.data != null &&
                        response.data!['order_id'] != null)
                      const SizedBox(height: 8),
                    Text('Payment Method: $paymentMethod'),
                    const SizedBox(height: 8),
                    Text('Total: Rs. ${totalAmount.toStringAsFixed(2)}'),
                    const SizedBox(height: 12),
                    const Text(
                      'You will receive a confirmation shortly.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      // Navigate back to home and reset navigation
                      final navigationProvider =
                          Provider.of<NavigationProvider>(
                            context,
                            listen: false,
                          );
                      navigationProvider.setCurrentIndex(0); // Set to home tab
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
        );
      }
    } catch (error) {
      setState(() {
        _isProcessingOrder = false;
      });

      if (mounted) {
        String errorMessage =
            'Sorry, there was an error processing your order. Please try again.';
        String errorDetails = error.toString();

        // Parse common errors for better user messages
        if (errorDetails.contains('shipping address')) {
          errorMessage =
              'Please check your shipping address details and try again.';
        } else if (errorDetails.contains('payment')) {
          errorMessage =
              'There was an issue with payment processing. Please try again.';
        } else if (errorDetails.contains('network') ||
            errorDetails.contains('connection')) {
          errorMessage =
              'Network connection issue. Please check your internet and try again.';
        } else if (errorDetails.contains('cart') ||
            errorDetails.contains('empty')) {
          errorMessage =
              'Your cart appears to be empty. Please add items before checkout.';
        }

        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Order Failed'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(errorMessage),
                    const SizedBox(height: 12),
                    ExpansionTile(
                      title: const Text(
                        'Technical Details',
                        style: TextStyle(fontSize: 14),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            errorDetails,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CheckoutForm(
              onSubmit:
                  _isProcessingOrder
                      ? null
                      : (name, address, phone, paymentMethod) =>
                          _handleFormSubmit(
                            context,
                            name,
                            address,
                            phone,
                            paymentMethod,
                          ),
            ),
          ),
          // Loading overlay
          if (_isProcessingOrder)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Processing Your Order...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please wait while we process your order',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
