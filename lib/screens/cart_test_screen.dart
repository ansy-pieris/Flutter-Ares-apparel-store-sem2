import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartTestScreen extends StatefulWidget {
  const CartTestScreen({super.key});

  @override
  State<CartTestScreen> createState() => _CartTestScreenState();
}

class _CartTestScreenState extends State<CartTestScreen> {
  final ApiService _apiService = ApiService();
  String _result = 'No test run yet';
  bool _isLoading = false;

  Future<void> _testCartAPI() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing cart API...';
    });

    try {
      // Test cart API
      final response = await _apiService.getCart();

      setState(() {
        _result = '''
Cart API Test Results:
===================
Success: ${response.success}
Error: ${response.error ?? 'None'}
Data: ${response.data}

Raw Response Structure:
${response.data.runtimeType}

If Data is Map:
${response.data is Map ? (response.data as Map).keys.join(', ') : 'Not a Map'}
        ''';
      });
    } catch (e) {
      setState(() {
        _result = 'Cart API Test Failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart API Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testCartAPI,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Test Cart API'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _result,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
