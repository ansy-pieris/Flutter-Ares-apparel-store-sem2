import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String name;
  final String image;

  const CategoryTile({required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 75,
          height: 75,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(image, fit: BoxFit.contain),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
