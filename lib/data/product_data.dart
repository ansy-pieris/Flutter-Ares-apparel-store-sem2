import '../models/product.dart';

/// Comprehensive hardcoded product data for master/detail functionality
/// Contains all products across different categories with full details
class ProductData {
  static List<Product> getAllProducts() {
    return [
      // Men's Clothing
      Product(
        id: 'men_001',
        name: 'Classic Denim Jacket',
        description:
            'Timeless denim jacket crafted from premium cotton denim. Features classic button closure, chest pockets, and a comfortable regular fit. Perfect for layering in any season.',
        price: 89.99,
        originalPrice: 119.99,
        image: 'assets/images/jacket.jpg',
        images: ['assets/images/jacket.jpg', 'assets/images/jacket.jpg'],
        category: 'Men',
        subcategory: 'Jackets',
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        colors: ['Blue', 'Black', 'Light Blue'],
        rating: 4.5,
        reviewCount: 128,
        inStock: true,
        stockQuantity: 50,
        brand: 'ARES',
        specifications: {
          'Material': '100% Cotton Denim',
          'Fit': 'Regular',
          'Care': 'Machine Wash Cold',
          'Origin': 'Made in USA',
        },
        tags: ['classic', 'denim', 'casual', 'layering'],
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        isFeatured: true,
        isOnSale: true,
      ),

      Product(
        id: 'men_002',
        name: 'Premium Cotton Hoodie',
        description:
            'Ultra-soft cotton hoodie with drawstring hood and kangaroo pocket. Perfect for casual wear and light workouts. Available in multiple colors.',
        price: 59.99,
        originalPrice: 59.99,
        image: 'assets/images/hoodie.webp',
        images: ['assets/images/hoodie.webp'],
        category: 'Men',
        subcategory: 'Hoodies',
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        colors: ['Gray', 'Black', 'Navy', 'Maroon'],
        rating: 4.3,
        reviewCount: 95,
        inStock: true,
        stockQuantity: 75,
        brand: 'ARES',
        specifications: {
          'Material': '80% Cotton, 20% Polyester',
          'Fit': 'Relaxed',
          'Care': 'Machine Wash Warm',
          'Weight': '12 oz',
        },
        tags: ['comfortable', 'casual', 'warm', 'cotton'],
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        isFeatured: false,
        isOnSale: false,
      ),

      Product(
        id: 'men_003',
        name: 'Cargo Pants',
        description:
            'Durable cargo pants with multiple pockets for functionality and style. Made from ripstop fabric for enhanced durability. Perfect for outdoor activities.',
        price: 79.99,
        originalPrice: 99.99,
        image: 'assets/images/cargo.webp',
        images: ['assets/images/cargo.webp'],
        category: 'Men',
        subcategory: 'Pants',
        sizes: ['30', '32', '34', '36', '38', '40'],
        colors: ['Khaki', 'Black', 'Olive', 'Gray'],
        rating: 4.2,
        reviewCount: 67,
        inStock: true,
        stockQuantity: 40,
        brand: 'ARES',
        specifications: {
          'Material': '65% Cotton, 35% Polyester Ripstop',
          'Pockets': '6 Total Pockets',
          'Care': 'Machine Wash Cold',
          'Fit': 'Regular',
        },
        tags: ['cargo', 'outdoor', 'functional', 'durable'],
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        isFeatured: false,
        isOnSale: true,
      ),

      Product(
        id: 'men_004',
        name: 'Classic Dress Shirt',
        description:
            'Elegant dress shirt perfect for business and formal occasions. Made from premium cotton with a comfortable regular fit and classic collar.',
        price: 69.99,
        originalPrice: 69.99,
        image: 'assets/images/shirt.jpg',
        images: ['assets/images/shirt.jpg', 'assets/images/shirts.jpg'],
        category: 'Men',
        subcategory: 'Shirts',
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        colors: ['White', 'Blue', 'Light Blue', 'Gray'],
        rating: 4.6,
        reviewCount: 203,
        inStock: true,
        stockQuantity: 85,
        brand: 'ARES',
        specifications: {
          'Material': '100% Premium Cotton',
          'Collar': 'Spread Collar',
          'Care': 'Dry Clean Preferred',
          'Fit': 'Regular',
        },
        tags: ['formal', 'business', 'dress', 'cotton'],
        createdAt: DateTime.now().subtract(Duration(days: 25)),
        isFeatured: true,
        isOnSale: false,
      ),

      Product(
        id: 'men_005',
        name: 'Slim Fit Jeans',
        description:
            'Modern slim-fit jeans crafted from stretch denim for comfort and style. Features a contemporary cut that flatters all body types.',
        price: 89.99,
        originalPrice: 109.99,
        image: 'assets/images/jeans.jpg',
        images: ['assets/images/jeans.jpg'],
        category: 'Men',
        subcategory: 'Jeans',
        sizes: ['30', '32', '34', '36', '38'],
        colors: ['Dark Blue', 'Black', 'Light Blue'],
        rating: 4.4,
        reviewCount: 156,
        inStock: true,
        stockQuantity: 60,
        brand: 'ARES',
        specifications: {
          'Material': '98% Cotton, 2% Elastane',
          'Fit': 'Slim',
          'Rise': 'Mid-Rise',
          'Care': 'Machine Wash Cold',
        },
        tags: ['jeans', 'slim', 'stretch', 'modern'],
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        isFeatured: false,
        isOnSale: true,
      ),

      // Women's Clothing
      Product(
        id: 'women_001',
        name: 'Elegant Blouse',
        description:
            'Sophisticated blouse perfect for professional and casual settings. Features delicate fabric and flattering cut that complements any wardrobe.',
        price: 49.99,
        originalPrice: 69.99,
        image: 'assets/images/blouse.jpg',
        images: ['assets/images/blouse.jpg', 'assets/images/shirts-w.jpg'],
        category: 'Women',
        subcategory: 'Blouses',
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        colors: ['White', 'Black', 'Navy', 'Rose'],
        rating: 4.5,
        reviewCount: 89,
        inStock: true,
        stockQuantity: 45,
        brand: 'ARES',
        specifications: {
          'Material': '100% Polyester',
          'Fit': 'Regular',
          'Care': 'Machine Wash Cold',
          'Style': 'Business Casual',
        },
        tags: ['blouse', 'professional', 'elegant', 'versatile'],
        createdAt: DateTime.now().subtract(Duration(days: 18)),
        isFeatured: true,
        isOnSale: true,
      ),

      Product(
        id: 'women_002',
        name: 'Crop Top',
        description:
            'Trendy crop top perfect for casual outings and layering. Made from soft, breathable fabric with a comfortable fit.',
        price: 29.99,
        originalPrice: 29.99,
        image: 'assets/images/crop.jpg',
        images: ['assets/images/crop.jpg', 'assets/images/crop.webp'],
        category: 'Women',
        subcategory: 'Tops',
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        colors: ['Black', 'White', 'Pink', 'Gray'],
        rating: 4.2,
        reviewCount: 134,
        inStock: true,
        stockQuantity: 70,
        brand: 'ARES',
        specifications: {
          'Material': '95% Cotton, 5% Elastane',
          'Fit': 'Fitted',
          'Care': 'Machine Wash Cold',
          'Length': 'Cropped',
        },
        tags: ['crop', 'casual', 'trendy', 'comfortable'],
        createdAt: DateTime.now().subtract(Duration(days: 12)),
        isFeatured: false,
        isOnSale: false,
      ),

      Product(
        id: 'women_003',
        name: 'High-Waisted Jeans',
        description:
            'Flattering high-waisted jeans that accentuate your silhouette. Made from premium stretch denim for all-day comfort.',
        price: 79.99,
        originalPrice: 99.99,
        image: 'assets/images/w-jeans.jpg',
        images: ['assets/images/w-jeans.jpg'],
        category: 'Women',
        subcategory: 'Jeans',
        sizes: ['24', '26', '28', '30', '32', '34'],
        colors: ['Dark Blue', 'Black', 'Light Blue'],
        rating: 4.7,
        reviewCount: 178,
        inStock: true,
        stockQuantity: 55,
        brand: 'ARES',
        specifications: {
          'Material': '99% Cotton, 1% Elastane',
          'Fit': 'High-Waisted',
          'Rise': 'High-Rise',
          'Care': 'Machine Wash Cold',
        },
        tags: ['jeans', 'high-waisted', 'flattering', 'comfortable'],
        createdAt: DateTime.now().subtract(Duration(days: 8)),
        isFeatured: true,
        isOnSale: true,
      ),

      Product(
        id: 'women_004',
        name: 'A-Line Skirt',
        description:
            'Classic A-line skirt that flatters all body types. Perfect for both professional and casual occasions.',
        price: 45.99,
        originalPrice: 45.99,
        image: 'assets/images/skirt.jpg',
        images: ['assets/images/skirt.jpg'],
        category: 'Women',
        subcategory: 'Skirts',
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        colors: ['Black', 'Navy', 'Gray', 'Burgundy'],
        rating: 4.3,
        reviewCount: 92,
        inStock: true,
        stockQuantity: 38,
        brand: 'ARES',
        specifications: {
          'Material': '70% Polyester, 30% Viscose',
          'Fit': 'A-Line',
          'Length': 'Knee-Length',
          'Care': 'Dry Clean Only',
        },
        tags: ['skirt', 'a-line', 'classic', 'versatile'],
        createdAt: DateTime.now().subtract(Duration(days: 22)),
        isFeatured: false,
        isOnSale: false,
      ),

      // Footwear
      Product(
        id: 'shoes_001',
        name: 'Athletic Sneakers',
        description:
            'High-performance athletic sneakers designed for comfort and durability. Features advanced cushioning and breathable materials.',
        price: 129.99,
        originalPrice: 159.99,
        image: 'assets/images/sneakers.jpeg',
        images: ['assets/images/sneakers.jpeg'],
        category: 'Footwear',
        subcategory: 'Sneakers',
        sizes: ['7', '8', '9', '10', '11', '12'],
        colors: ['White', 'Black', 'Gray', 'Blue'],
        rating: 4.6,
        reviewCount: 245,
        inStock: true,
        stockQuantity: 80,
        brand: 'ARES',
        specifications: {
          'Material': 'Synthetic Upper, Rubber Sole',
          'Cushioning': 'Air Cushioned',
          'Support': 'Arch Support',
          'Activity': 'Running, Training',
        },
        tags: ['sneakers', 'athletic', 'comfortable', 'running'],
        createdAt: DateTime.now().subtract(Duration(days: 35)),
        isFeatured: true,
        isOnSale: true,
      ),

      Product(
        id: 'shoes_002',
        name: 'Leather Boots',
        description:
            'Premium leather boots built for durability and style. Perfect for casual and semi-formal occasions.',
        price: 189.99,
        originalPrice: 189.99,
        image: 'assets/images/boots.webp',
        images: ['assets/images/boots.webp'],
        category: 'Footwear',
        subcategory: 'Boots',
        sizes: ['7', '8', '9', '10', '11', '12'],
        colors: ['Brown', 'Black', 'Tan'],
        rating: 4.5,
        reviewCount: 87,
        inStock: true,
        stockQuantity: 35,
        brand: 'ARES',
        specifications: {
          'Material': '100% Genuine Leather',
          'Sole': 'Rubber Sole',
          'Lining': 'Textile Lining',
          'Construction': 'Goodyear Welt',
        },
        tags: ['boots', 'leather', 'durable', 'classic'],
        createdAt: DateTime.now().subtract(Duration(days: 40)),
        isFeatured: false,
        isOnSale: false,
      ),

      Product(
        id: 'shoes_003',
        name: 'High Heels',
        description:
            'Elegant high heels perfect for formal events and special occasions. Features comfortable heel height and stylish design.',
        price: 99.99,
        originalPrice: 129.99,
        image: 'assets/images/heels.webp',
        images: ['assets/images/heels.webp'],
        category: 'Footwear',
        subcategory: 'Heels',
        sizes: ['6', '7', '8', '9', '10'],
        colors: ['Black', 'Nude', 'Red', 'Navy'],
        rating: 4.2,
        reviewCount: 156,
        inStock: true,
        stockQuantity: 42,
        brand: 'ARES',
        specifications: {
          'Material': 'Synthetic Upper',
          'Heel Height': '3.5 inches',
          'Sole': 'Non-slip Sole',
          'Occasion': 'Formal, Party',
        },
        tags: ['heels', 'formal', 'elegant', 'party'],
        createdAt: DateTime.now().subtract(Duration(days: 28)),
        isFeatured: false,
        isOnSale: true,
      ),

      // Accessories
      Product(
        id: 'acc_001',
        name: 'Luxury Watch',
        description:
            'Premium timepiece with precision movement and elegant design. Perfect accessory for any outfit, suitable for both casual and formal wear.',
        price: 299.99,
        originalPrice: 399.99,
        image: 'assets/images/watch.jpg',
        images: ['assets/images/watch.jpg'],
        category: 'Accessories',
        subcategory: 'Watches',
        sizes: ['One Size'],
        colors: ['Gold', 'Silver', 'Black', 'Rose Gold'],
        rating: 4.8,
        reviewCount: 312,
        inStock: true,
        stockQuantity: 25,
        brand: 'ARES',
        specifications: {
          'Movement': 'Quartz',
          'Water Resistance': '50m',
          'Case Material': 'Stainless Steel',
          'Warranty': '2 Years',
        },
        tags: ['watch', 'luxury', 'timepiece', 'elegant'],
        createdAt: DateTime.now().subtract(Duration(days: 45)),
        isFeatured: true,
        isOnSale: true,
      ),

      Product(
        id: 'acc_002',
        name: 'Leather Wallet',
        description:
            'Handcrafted leather wallet with multiple card slots and bill compartments. Made from premium genuine leather for durability.',
        price: 49.99,
        originalPrice: 49.99,
        image: 'assets/images/wallet.webp',
        images: ['assets/images/wallet.webp'],
        category: 'Accessories',
        subcategory: 'Wallets',
        sizes: ['One Size'],
        colors: ['Brown', 'Black', 'Tan'],
        rating: 4.4,
        reviewCount: 128,
        inStock: true,
        stockQuantity: 65,
        brand: 'ARES',
        specifications: {
          'Material': '100% Genuine Leather',
          'Card Slots': '8 Slots',
          'Bill Compartments': '2 Compartments',
          'Dimensions': '4.5" x 3.5" x 0.8"',
        },
        tags: ['wallet', 'leather', 'handcrafted', 'practical'],
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        isFeatured: false,
        isOnSale: false,
      ),

      Product(
        id: 'acc_003',
        name: 'Baseball Cap',
        description:
            'Classic baseball cap with adjustable strap and comfortable fit. Perfect for casual outings and sports activities.',
        price: 24.99,
        originalPrice: 34.99,
        image: 'assets/images/cap.jpg',
        images: ['assets/images/cap.jpg'],
        category: 'Accessories',
        subcategory: 'Hats',
        sizes: ['One Size'],
        colors: ['Black', 'Navy', 'Gray', 'White'],
        rating: 4.1,
        reviewCount: 89,
        inStock: true,
        stockQuantity: 95,
        brand: 'ARES',
        specifications: {
          'Material': '100% Cotton Twill',
          'Closure': 'Adjustable Strap',
          'Brim': 'Curved Brim',
          'Care': 'Hand Wash Only',
        },
        tags: ['cap', 'baseball', 'casual', 'adjustable'],
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        isFeatured: false,
        isOnSale: true,
      ),
    ];
  }

  /// Get products by category
  static List<Product> getProductsByCategory(String category) {
    return getAllProducts()
        .where((product) => product.category == category)
        .toList();
  }

  /// Get featured products
  static List<Product> getFeaturedProducts() {
    return getAllProducts().where((product) => product.isFeatured).toList();
  }

  /// Get products on sale
  static List<Product> getOnSaleProducts() {
    return getAllProducts().where((product) => product.isOnSale).toList();
  }

  /// Get product by ID
  static Product? getProductById(String id) {
    try {
      return getAllProducts().firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search products by name
  static List<Product> searchProducts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getAllProducts()
        .where(
          (product) =>
              product.name.toLowerCase().contains(lowercaseQuery) ||
              product.description.toLowerCase().contains(lowercaseQuery) ||
              product.tags.any(
                (tag) => tag.toLowerCase().contains(lowercaseQuery),
              ),
        )
        .toList();
  }

  /// Get products by subcategory
  static List<Product> getProductsBySubcategory(String subcategory) {
    return getAllProducts()
        .where((product) => product.subcategory == subcategory)
        .toList();
  }

  /// Get all categories
  static List<String> getAllCategories() {
    return getAllProducts().map((product) => product.category).toSet().toList();
  }

  /// Get all subcategories for a category
  static List<String> getSubcategoriesForCategory(String category) {
    return getAllProducts()
        .where((product) => product.category == category)
        .map((product) => product.subcategory)
        .toSet()
        .toList();
  }
}
