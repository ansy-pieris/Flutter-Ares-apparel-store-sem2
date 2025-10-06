import 'package:flutter/material.dart';

class CartItemTile extends StatelessWidget {
  final String name;
  final double price;
  final String image;
  final int quantity;

  const CartItemTile({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(image, width: 50, height: 50, fit: BoxFit.cover),
      title: Text(name),
      subtitle: Text("Price: \LKR ${price.toStringAsFixed(2)}\nQty: $quantity"),
      isThreeLine: true,
    );
  }
}
