import 'package:store_buy/model/product_model.dart';

class CartItem {
  final String? cartId;
  final String userId;
  final String productId;
  final int quantity;
  final Product? product;
  final String? storeName;
  final String? storeId;

  CartItem({
    this.cartId,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.product,
    this.storeName,
    this.storeId,
  });

  double get totalPrice => (product?.price ?? 0) * quantity;

  Map<String, dynamic> toMap() {
    return {
      'cartId': cartId,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class Panier {
  final String userId;
  final List<CartItem> items;
  final double solde;
  final double alerte;

  Panier({
    required this.userId,
    required this.items,
    this.solde = 0.0,
    this.alerte = 0.0,
  });

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}