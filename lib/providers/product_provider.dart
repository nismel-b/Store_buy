import 'package:flutter/foundation.dart';
import 'package:store_buy/model/product_model.dart';
import 'package:store_buy/service/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _searchQuery;
  String? _selectedCategory;

  List<Product> get products => _filteredProducts.isEmpty && _searchQuery == null && _selectedCategory == null
      ? _products
      : _filteredProducts;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _productService.getAllProducts();
      _products = data.map((item) => Product.fromMap(item)).toList();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProductsByStore(String storeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _productService.getProductsByStore(storeId);
      _products = data.map((item) => Product.fromMap(item)).toList();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading products by store: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query.isEmpty ? null : query;
    _isLoading = true;
    notifyListeners();

    try {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        final data = await _productService.searchProducts(query);
        _filteredProducts = data.map((item) => Product.fromMap(item)).toList();
      }
    } catch (e) {
      debugPrint('Error searching products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    if (_searchQuery == null && _selectedCategory == null) {
      _filteredProducts = _products;
      return;
    }

    _filteredProducts = _products.where((product) {
      bool matches = true;

      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        matches = matches &&
            (product.productName.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
                product.characteristic.toLowerCase().contains(_searchQuery!.toLowerCase()));
      }

      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        matches = matches && product.category == _selectedCategory;
      }

      return matches;
    }).toList();

    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedCategory = null;
    _filteredProducts = [];
    notifyListeners();
  }
}


