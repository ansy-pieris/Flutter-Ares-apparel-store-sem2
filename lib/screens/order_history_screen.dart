import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getOrders();
      if (response.success && response.data != null) {
        setState(() {
          _orders = response.data is List ? response.data : [response.data];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load orders';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading orders: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshOrders() async {
    await _loadOrders();
  }

  void _showOrderDetails(dynamic order) {
    showDialog(
      context: context,
      builder:
          (context) => OrderDetailsDialog(
            order: order,
            onTrackOrder: (orderNumber) => _trackOrder(orderNumber),
            onCancelOrder: (orderId) => _cancelOrder(orderId),
          ),
    );
  }

  Future<void> _trackOrder(String orderNumber) async {
    try {
      final response = await _apiService.trackOrder(orderNumber);
      if (response.success && response.data != null) {
        _showTrackingInfo(response.data);
      } else {
        _showErrorSnackBar('Failed to track order: ${response.error}');
      }
    } catch (e) {
      _showErrorSnackBar('Error tracking order: $e');
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    final confirmed = await _showCancelConfirmation();
    if (!confirmed) return;

    try {
      final response = await _apiService.cancelOrder(orderId);
      if (response.success) {
        _showSuccessSnackBar('Order cancelled successfully');
        _refreshOrders();
      } else {
        _showErrorSnackBar('Failed to cancel order: ${response.error}');
      }
    } catch (e) {
      _showErrorSnackBar('Error cancelling order: $e');
    }
  }

  Future<bool> _showCancelConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Cancel Order'),
                content: const Text(
                  'Are you sure you want to cancel this order?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Yes, Cancel'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showTrackingInfo(dynamic trackingData) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Order Tracking'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trackingData['status'] != null)
                    Text('Status: ${trackingData['status']}'),
                  if (trackingData['tracking_number'] != null)
                    Text('Tracking Number: ${trackingData['tracking_number']}'),
                  if (trackingData['estimated_delivery'] != null)
                    Text(
                      'Estimated Delivery: ${trackingData['estimated_delivery']}',
                    ),
                  if (trackingData['last_updated'] != null)
                    Text('Last Updated: ${trackingData['last_updated']}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you place orders, they will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return OrderCard(
          order: order,
          isDark: isDark,
          onTap: () => _showOrderDetails(order),
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final dynamic order;
  final bool isDark;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final orderId = order['id']?.toString() ?? 'N/A';
    final total = order['total_amount']?.toString() ?? '0.00';
    final status = order['status']?.toString() ?? 'Unknown';
    final date = order['created_at']?.toString() ?? '';

    // Format date if available
    String formattedDate = '';
    if (date.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(date);
        formattedDate =
            '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      } catch (e) {
        formattedDate = date;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #$orderId',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: Rs. $total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  if (formattedDate.isNotEmpty)
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tap for details',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class OrderDetailsDialog extends StatelessWidget {
  final dynamic order;
  final Function(String) onTrackOrder;
  final Function(String) onCancelOrder;

  const OrderDetailsDialog({
    super.key,
    required this.order,
    required this.onTrackOrder,
    required this.onCancelOrder,
  });

  @override
  Widget build(BuildContext context) {
    final orderId = order['id']?.toString() ?? 'N/A';
    final orderNumber = order['order_number']?.toString() ?? orderId;
    final total = order['total_amount']?.toString() ?? '0.00';
    final status = order['status']?.toString() ?? 'Unknown';
    final customerName = order['customer_name']?.toString() ?? '';
    final customerPhone = order['customer_phone']?.toString() ?? '';
    final shippingAddress = order['shipping_address']?.toString() ?? '';
    final paymentMethod = order['payment_method']?.toString() ?? '';
    final items = order['items'] as List? ?? [];

    final canCancel = ['pending', 'processing'].contains(status.toLowerCase());
    final canTrack = ['processing', 'shipped'].contains(status.toLowerCase());

    return AlertDialog(
      title: Text('Order #$orderId'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Status', status),
            _buildDetailRow('Total', 'Rs. $total'),
            if (customerName.isNotEmpty)
              _buildDetailRow('Customer', customerName),
            if (customerPhone.isNotEmpty)
              _buildDetailRow('Phone', customerPhone),
            if (shippingAddress.isNotEmpty)
              _buildDetailRow('Address', shippingAddress),
            if (paymentMethod.isNotEmpty)
              _buildDetailRow('Payment', paymentMethod),

            if (items.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• ${item['product_name'] ?? 'Unknown'} x${item['quantity'] ?? 1}',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (canTrack)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onTrackOrder(orderNumber);
            },
            icon: const Icon(Icons.local_shipping),
            label: const Text('Track'),
          ),
        if (canCancel)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onCancelOrder(orderId);
            },
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
