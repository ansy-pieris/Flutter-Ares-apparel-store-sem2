import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

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
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();
  final _phoneController = TextEditingController();

  String paymentMethod = 'Cash on Delivery';
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Load user profile data if available
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      await profileProvider.fetchProfile();

      final profile = profileProvider.userProfile;
      if (profile != null) {
        _nameController.text = profile.fullName;
        _phoneController.text = profile.phone;
        _streetController.text = profile.streetAddress;
        _cityController.text = profile.city;
        _postalController.text = profile.postalCode;
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && widget.onSubmit != null) {
      // Combine address components into a formatted string
      final fullAddress =
          '${_streetController.text}, ${_cityController.text}, ${_postalController.text}';
      widget.onSubmit!(
        _nameController.text,
        fullAddress,
        _phoneController.text,
        paymentMethod,
      );
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
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Recipient Name'),
            validator:
                (value) => value!.isEmpty ? 'Enter recipient name' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _streetController,
            decoration: const InputDecoration(
              labelText: 'Street Address',
              hintText: 'e.g., 123 Main Street, Apt 4B',
            ),
            validator:
                (value) => value!.isEmpty ? 'Enter street address' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'City'),
            validator: (value) => value!.isEmpty ? 'Enter city' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _postalController,
            decoration: const InputDecoration(
              labelText: 'Postal Code',
              hintText: 'e.g., 12345',
            ),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Enter postal code' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter phone number';
              }
              if (value.length < 10) {
                return 'Phone number must be at least 10 digits';
              }
              return null;
            },
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
