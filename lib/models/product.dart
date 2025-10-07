class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String image;
  final List<String> images;
  final String category;
  final String subcategory;
  final List<String> sizes;
  final List<String> colors;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final int stockQuantity;
  final String brand;
  final Map<String, String> specifications;
  final List<String> tags;
  final DateTime createdAt;
  final bool isFeatured;
  final bool isOnSale;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.image,
    required this.images,
    required this.category,
    required this.subcategory,
    required this.sizes,
    required this.colors,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.stockQuantity,
    required this.brand,
    required this.specifications,
    required this.tags,
    required this.createdAt,
    required this.isFeatured,
    required this.isOnSale,
  });

  double get discountPercentage {
    if (originalPrice <= price) return 0.0;
    return ((originalPrice - price) / originalPrice * 100);
  }

  bool get hasDiscount => originalPrice > price;
  String get formattedPrice => "Rs. ${price.toStringAsFixed(2)}";
  String get formattedOriginalPrice =>
      "Rs. ${originalPrice.toStringAsFixed(2)}";
  String get primaryImage =>
      image.isNotEmpty ? image : (images.isNotEmpty ? images.first : "");

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle category - can be string or object
    final categoryData = json['category'];
    String categoryName = '';
    if (categoryData is Map<String, dynamic>) {
      categoryName = categoryData['name']?.toString() ?? '';
    } else if (categoryData is String) {
      categoryName = categoryData;
    }

    return Product(
      id: json['id']?.toString() ?? json['product_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description:
          json['description']?.toString() ?? 'No description available',
      price: _parseDouble(json['price']),
      originalPrice: _parseDouble(json['original_price'] ?? json['price']),
      image: _parseImageUrl(json['image']?.toString() ?? ''),
      images: _parseImages(json['images'] ?? json['image']),
      category: categoryName,
      subcategory: json['subcategory']?.toString() ?? categoryName,
      sizes: _parseStringList(json['sizes']),
      colors: _parseStringList(json['colors']),
      rating: _parseDouble(json['rating'] ?? json['average_rating']),
      reviewCount: _parseInt(
        json['review_count'] ?? json['reviews_count'] ?? json['total_reviews'],
      ),
      inStock: _parseBool(
        json['stock_status'] == 'In Stock'
            ? true
            : json['in_stock'] ??
                json['is_available'] ??
                json['available'] ??
                true,
      ),
      stockQuantity: _parseInt(
        json['stock'] ?? json['stock_quantity'] ?? json['quantity'],
      ),
      brand: json['brand']?.toString() ?? 'Ares Apparel',
      specifications: _parseSpecifications(
        json['specifications'] ?? json['specs'],
      ),
      tags: _parseStringList(json['tags']),
      createdAt: _parseDateTime(json['created_at']),
      isFeatured: _parseBool(json['is_featured'] ?? json['featured']),
      isOnSale:
          _parseBool(json['is_on_sale'] ?? json['on_sale']) ||
          (_parseDouble(json['original_price']) > _parseDouble(json['price'])),
    );
  }

  static String _parseImageUrl(String imageValue) {
    if (imageValue.isEmpty) return '';

    // If already a full URL, return as is
    if (imageValue.startsWith('http://') || imageValue.startsWith('https://')) {
      print('✅ Image URL (already full): $imageValue');
      return imageValue;
    }

    // If it's just a filename, construct the full URL
    const baseUrl = 'http://13.204.86.61/storage/products/';
    final fullUrl = '$baseUrl$imageValue';
    print('🔧 Image URL (constructed): $fullUrl');
    return fullUrl;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (value is String && value.isNotEmpty) {
      try {
        // Try to parse as JSON array
        final decoded = value.startsWith('[') ? value : '["$value"]';
        final list =
            decoded
                .split(',')
                .map((e) => e.trim().replaceAll(RegExp(r'[\[\]"]'), ''))
                .toList();
        return list.where((s) => s.isNotEmpty).toList();
      } catch (e) {
        return [value];
      }
    }
    return [];
  }

  static List<String> _parseImages(dynamic value) {
    final images = _parseStringList(value);
    return images.map((img) => _parseImageUrl(img)).toList();
  }

  static Map<String, String> _parseSpecifications(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) {
      final result = <String, String>{};
      value.forEach((key, val) {
        result[key] = val?.toString() ?? '';
      });
      return result;
    }
    return {};
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'image': image,
      'images': images,
      'category': category,
      'subcategory': subcategory,
      'sizes': sizes,
      'colors': colors,
      'rating': rating,
      'review_count': reviewCount,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'brand': brand,
      'specifications': specifications,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'is_featured': isFeatured,
      'is_on_sale': isOnSale,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, category: $category}';
  }
}
