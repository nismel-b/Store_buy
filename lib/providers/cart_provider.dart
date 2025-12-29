import 'package:flutter/foundation.dart';
import 'package:store_buy/model/panier_model.dart';
import 'package:store_buy/service/cart_service.dart';
import 'package:store_buy/model/product_model.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _userId;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  void setUserId(String userId) {
    _userId = userId;
    loadCart();
  }

  Future<void> loadCart() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final items = await _cartService.getCartItems(_userId!);
      _cartItems = items.map((item) {
        return CartItem(
          cartId: item['cartId'] as String?,
          userId: _userId!,
          productId: item['productId'] as String,
          quantity: item['quantity'] as int,
          product: Product.fromMap(item),
          storeName: item['storename'] as String?,
          storeId: item['storeId'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToCart(Product product, {int quantity = 1}) async {
    if (_userId == null) return false;

    try {
      final success = await _cartService.addToCart(
        userId: _userId!,
        productId: product.productId!,
        quantity: quantity,
      );
      if (success) {
        await loadCart();
        return true;
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
    return false;
  }

  Future<bool> updateQuantity(String productId, int quantity) async {
    if (_userId == null) return false;

    try {
      final success = await _cartService.updateCartItemQuantity(
        userId: _userId!,
        productId: productId,
        quantity: quantity,
      );
      if (success) {
        await loadCart();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
    return false;
  }

  Future<bool> removeFromCart(String productId) async {
    if (_userId == null) return false;

    try {
      final success = await _cartService.removeFromCart(_userId!, productId);
      if (success) {
        await loadCart();
        return true;
      }
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
    return false;
  }

  Future<bool> clearCart() async {
    if (_userId == null) return false;

    try {
      final success = await _cartService.clearCart(_userId!);
      if (success) {
        _cartItems = [];
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
    return false;
  }
}


