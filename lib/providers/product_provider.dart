import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

/// Provider class to manage product data via Laravel API
/// Handles product fetching, filtering, search, pagination, and navigation state
class ProductProvider with ChangeNotifier {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  Product? _selectedProduct;
  String _selectedCategory = 'All';
  String _selectedSubcategory = 'All';
  String _searchQuery = '';
  bool _showOnlyFeatured = false;
  bool _showOnlySale = false;
  String _sortBy = 'name'; // name, price_low, price_high, rating, newest

  // API state management
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isRefreshing = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  // Cached category data for synchronous access
  List<String> _availableCategories = ['All'];
  List<String> _availableSubcategories = ['All'];

  final ApiService _apiService = ApiService();

  // Getters for accessing product state
  List<Product> get allProducts => List.unmodifiable(_allProducts);
  List<Product> get filteredProducts => List.unmodifiable(_filteredProducts);
  Product? get selectedProduct => _selectedProduct;
  String get selectedCategory => _selectedCategory;
  String get selectedSubcategory => _selectedSubcategory;
  String get searchQuery => _searchQuery;
  bool get showOnlyFeatured => _showOnlyFeatured;
  bool get showOnlySale => _showOnlySale;
  String get sortBy => _sortBy;

  // API state getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isRefreshing => _isRefreshing;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;

  /// Clear error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initialize product data from API
  Future<void> initializeProducts() async {
    if (_isInitialized && _allProducts.isNotEmpty) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await fetchProducts(refresh: true);
      await _fetchAndCacheCategories();
      _isInitialized = true;
    } catch (error) {
      debugPrint('Initialize products error: $error');
      _errorMessage = 'Failed to load products. Please try again.';
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch products from API with pagination
  Future<void> fetchProducts({bool refresh = false, int page = 1}) async {
    try {
      if (refresh) {
        _isRefreshing = true;
        _currentPage = 1;
        _allProducts.clear();
      } else {
        _isLoading = true;
      }
      _errorMessage = null;
      notifyListeners();

      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': '20',
      };

      if (_selectedCategory != 'All') {
        queryParams['category'] = _selectedCategory;
      }
      if (_selectedSubcategory != 'All') {
        queryParams['subcategory'] = _selectedSubcategory;
      }
      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }
      if (_showOnlyFeatured) {
        queryParams['featured'] = '1';
      }
      if (_showOnlySale) {
        queryParams['on_sale'] = '1';
      }
      if (_sortBy != 'name') {
        queryParams['sort'] = _sortBy;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');

      final response = await _apiService.get('/products?$queryString');

      if (response.success && response.data != null) {
        final data = response.data;
        // Handle both response structures: direct data or nested data.data
        final actualData = data['data'] ?? data;
        final productsList = actualData['products'] as List<dynamic>? ?? [];
        final pagination =
            actualData['pagination'] as Map<String, dynamic>? ?? {};

        final newProducts =
            productsList.map((json) => Product.fromJson(json)).toList();

        if (refresh) {
          _allProducts = newProducts;
        } else {
          _allProducts.addAll(newProducts);
        }

        _currentPage = pagination['current_page'] ?? 1;
        _totalPages = pagination['last_page'] ?? 1;
        _hasMore = _currentPage < _totalPages;

        // Update categories from loaded products
        if (refresh) {
          _updateCategoriesFromProducts();
        }

        _applyFilters();
      } else {
        _errorMessage = response.error ?? 'Failed to load products';
      }
    } catch (error) {
      debugPrint('Fetch products error: $error');
      _errorMessage = 'Failed to load products. Please check your connection.';
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (!_hasMore || _isLoading) return;
    await fetchProducts(page: _currentPage + 1);
  }

  /// Refresh products from API
  Future<void> refreshProducts() async {
    await fetchProducts(refresh: true);
  }

  /// Select a specific product for detail view
  void selectProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }

  /// Clear selected product (return to master list)
  void clearSelection() {
    _selectedProduct = null;
    notifyListeners();
  }

  /// Get product by ID from API and select it
  Future<void> selectProductById(String productId) async {
    try {
      final response = await _apiService.get('/products/$productId');
      if (response.success && response.data != null) {
        final productData = response.data['data'] ?? response.data;
        final product = Product.fromJson(productData);
        selectProduct(product);
      } else {
        _errorMessage = response.error ?? 'Product not found';
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Select product by ID error: $error');
      _errorMessage = 'Failed to load product details';
      notifyListeners();
    }
  }

  /// Set category filter and refresh products from API
  Future<void> setCategory(String category) async {
    _selectedCategory = category;
    _selectedSubcategory = 'All'; // Reset subcategory when category changes
    _updateSubcategories(); // Update subcategories immediately
    notifyListeners(); // Update UI immediately for better UX
    await fetchProducts(refresh: true);
  }

  /// Set subcategory filter and refresh products from API
  Future<void> setSubcategory(String subcategory) async {
    _selectedSubcategory = subcategory;
    await fetchProducts(refresh: true);
  }

  /// Set search query and refresh products from API
  Future<void> setSearchQuery(String query) async {
    _searchQuery = query.trim();
    await fetchProducts(refresh: true);
  }

  /// Toggle featured products filter
  Future<void> toggleFeaturedFilter() async {
    _showOnlyFeatured = !_showOnlyFeatured;
    await fetchProducts(refresh: true);
  }

  /// Toggle sale products filter
  Future<void> toggleSaleFilter() async {
    _showOnlySale = !_showOnlySale;
    await fetchProducts(refresh: true);
  }

  /// Set sort criteria and refresh products from API
  Future<void> setSortBy(String sortBy) async {
    _sortBy = sortBy;
    await fetchProducts(refresh: true);
  }

  /// Clear all filters and search
  Future<void> clearFilters() async {
    _selectedCategory = 'All';
    _selectedSubcategory = 'All';
    _searchQuery = '';
    _showOnlyFeatured = false;
    _showOnlySale = false;
    _sortBy = 'name';
    await fetchProducts(refresh: true);
  }

  /// Apply all current filters and sorting to products
  void _applyFilters() {
    List<Product> products = List.from(_allProducts);

    // Apply category filter
    if (_selectedCategory != 'All') {
      products =
          products
              .where((product) => product.category == _selectedCategory)
              .toList();
    }

    // Apply subcategory filter
    if (_selectedSubcategory != 'All') {
      products =
          products
              .where((product) => product.subcategory == _selectedSubcategory)
              .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowercaseQuery = _searchQuery.toLowerCase();
      products =
          products
              .where(
                (product) =>
                    product.name.toLowerCase().contains(lowercaseQuery) ||
                    product.description.toLowerCase().contains(
                      lowercaseQuery,
                    ) ||
                    product.brand.toLowerCase().contains(lowercaseQuery) ||
                    product.tags.any(
                      (tag) => tag.toLowerCase().contains(lowercaseQuery),
                    ),
              )
              .toList();
    }

    // Apply featured filter
    if (_showOnlyFeatured) {
      products = products.where((product) => product.isFeatured).toList();
    }

    // Apply sale filter
    if (_showOnlySale) {
      products = products.where((product) => product.isOnSale).toList();
    }

    // Apply sorting
    _applySorting(products);

    _filteredProducts = products;
    notifyListeners();
  }

  /// Apply sorting to the product list
  void _applySorting(List<Product> products) {
    switch (_sortBy) {
      case 'name':
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
        products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default:
        products.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  /// Get available categories (cached for synchronous access)
  List<String> getAvailableCategories() {
    return List.unmodifiable(_availableCategories);
  }

  /// Fetch and cache available categories from API
  Future<void> _fetchAndCacheCategories() async {
    try {
      final response = await _apiService.get('/categories');
      if (response.success && response.data != null) {
        final categories = ['All'];
        final categoryList = response.data['data'] as List<dynamic>? ?? [];
        categories.addAll(categoryList.map((cat) => cat['name'].toString()));
        _availableCategories = categories;
      } else {
        // Fallback to local categories if API fails
        _updateCategoriesFromProducts();
      }
    } catch (error) {
      debugPrint('Fetch categories error: $error');
      // Fallback to local categories if API fails
      _updateCategoriesFromProducts();
    }
  }

  /// Update categories from loaded products (fallback)
  void _updateCategoriesFromProducts() {
    final localCategories =
        _allProducts
            .map((p) => p.category)
            .where((cat) => cat.isNotEmpty)
            .toSet()
            .toList();
    localCategories.sort();
    _availableCategories = ['All', ...localCategories];
    _updateSubcategories();
  }

  /// Get available subcategories for current category (cached)
  List<String> getAvailableSubcategories() {
    return List.unmodifiable(_availableSubcategories);
  }

  /// Update subcategories based on selected category
  void _updateSubcategories() {
    if (_selectedCategory == 'All') {
      _availableSubcategories = ['All'];
    } else {
      final subcategories =
          _allProducts
              .where((p) => p.category == _selectedCategory)
              .map((p) => p.subcategory)
              .where((sub) => sub.isNotEmpty)
              .toSet()
              .toList();
      subcategories.sort();
      _availableSubcategories = ['All', ...subcategories];
    }
  }

  /// Get products count for current filters
  int get filteredProductsCount => _filteredProducts.length;

  /// Get total products count
  int get totalProductsCount => _allProducts.length;

  /// Check if any filters are active
  bool get hasActiveFilters {
    return _selectedCategory != 'All' ||
        _selectedSubcategory != 'All' ||
        _searchQuery.isNotEmpty ||
        _showOnlyFeatured ||
        _showOnlySale ||
        _sortBy != 'name';
  }

  /// Get similar products from API based on category and subcategory
  Future<List<Product>> getSimilarProducts(
    Product product, {
    int limit = 4,
  }) async {
    try {
      final response = await _apiService.get(
        '/products/similar/${product.id}?limit=$limit',
      );
      if (response.success && response.data != null) {
        final productsList = response.data as List;
        return productsList.map((json) => Product.fromJson(json)).toList();
      }
    } catch (error) {
      debugPrint('Get similar products error: $error');
    }

    // Fallback to local similar products
    return _allProducts
        .where(
          (p) =>
              p.id != product.id &&
              (p.category == product.category ||
                  p.subcategory == product.subcategory),
        )
        .take(limit)
        .toList();
  }

  /// Get featured products from API
  Future<List<Product>> getFeaturedProducts({int limit = 5}) async {
    try {
      final response = await _apiService.get('/products/featured?limit=$limit');
      if (response.success && response.data != null) {
        final productsList = response.data as List;
        return productsList.map((json) => Product.fromJson(json)).toList();
      }
    } catch (error) {
      debugPrint('Get featured products error: $error');
    }

    // Fallback to local featured products
    return _allProducts.where((p) => p.isFeatured).take(limit).toList();
  }
}
