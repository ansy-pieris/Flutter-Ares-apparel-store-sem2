import 'package:apparel_store/widgets/checkout_form.dart';
import 'package:flutter/material.dart';
import 'checkout_form.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  void _handleFormSubmit(BuildContext context, String name, String address, String phone, String paymentMethod) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Order Placed'),
        content: Text('Thank you, $name!\nYour order has been placed with "$paymentMethod".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CheckoutForm(
          onSubmit: (name, address, phone, paymentMethod) =>
              _handleFormSubmit(context, name, address, phone, paymentMethod),
        ),
      ),
    );
  }
}
