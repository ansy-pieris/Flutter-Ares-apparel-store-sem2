import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String name;
  final String image;

  const CategoryTile({required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, 
      children: [
        Container(
          width: 75, 
          height: 75,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(image, fit: BoxFit.contain),
        ),
        SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
