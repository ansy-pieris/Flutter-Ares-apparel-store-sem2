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
      // Get cart information for order details
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Check if cart is empty
      if (cartProvider.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Get total amount before clearing cart
      final totalAmount = cartProvider.totalAmount;

      // Process order through API
      final response = await _apiService.checkout(
        customerName: name,
        customerPhone: phone,
        shippingAddress: address,
        paymentMethod: paymentMethod,
      );

      if (!response.success) {
        throw Exception(response.error ?? 'Order processing failed');
      }

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
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Order Failed'),
                content: Text(
                  'Sorry, there was an error processing your order. Please try again.\n\nError: $error',
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
