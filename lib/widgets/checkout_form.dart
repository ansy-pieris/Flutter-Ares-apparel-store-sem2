import 'package:flutter/material.dart';

class CheckoutForm extends StatefulWidget {
  final void Function(
    String fullName,
    String address,
    String phone,
    String paymentMethod,
  )?
  onSubmit;

  const CheckoutForm({super.key, required this.onSubmit});

  @override
  State<CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<CheckoutForm> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String address = '';
  String phone = '';
  String paymentMethod = 'Cash on Delivery';

  void _submit() {
    if (_formKey.currentState!.validate() && widget.onSubmit != null) {
      _formKey.currentState!.save();
      widget.onSubmit!(fullName, address, phone, paymentMethod);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium;

    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            "Shipping Details",
            style: textStyle?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Full Name'),
            validator: (value) => value!.isEmpty ? 'Enter your name' : null,
            onSaved: (value) => fullName = value!,
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Address'),
            validator: (value) => value!.isEmpty ? 'Enter your address' : null,
            onSaved: (value) => address = value!,
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Enter your phone number';
              if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                return 'Phone number must be exactly 10 digits';
              }
              return null;
            },
            onSaved: (value) => phone = value!,
          ),
          const SizedBox(height: 20),

          Text(
            "Payment Method",
            style: textStyle?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          RadioListTile<String>(
            title: const Text('Cash on Delivery'),
            value: 'Cash on Delivery',
            groupValue: paymentMethod,
            onChanged: (value) => setState(() => paymentMethod = value!),
          ),
          RadioListTile<String>(
            title: const Text('Card Payment'),
            value: 'Card Payment',
            groupValue: paymentMethod,
            onChanged: (value) => setState(() => paymentMethod = value!),
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onSubmit != null ? _submit : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Place Order', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
