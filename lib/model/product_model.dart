// ajouter un produit dans le panier
class Product {
  final String? productId;
  final String? storeId;
  final String productName;
  final String characteristic;
  final List<String> color;
  final String photo;
  final double price;
  final int quantity;
  final String? category;
  final bool isPromoted;

  Product({
    this.productId,
    this.storeId,
    required this.productName,
    required this.characteristic,
    required this.color,
    required this.photo,
    required this.price,
    required this.quantity,
    this.category,
    this.isPromoted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'storeId': storeId,
      'productName': productName,
      'characteristic': characteristic,
      'color': color.join(','),
      'photo': photo,
      'price': price,
      'quantity': quantity,
      'category': category,
      'isPromoted': isPromoted ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['productId'] as String?,
      storeId: map['storeId'] as String?,
      productName: map['productName'] as String,
      characteristic: map['characteristic'] as String? ?? '',
      color: (map['color'] as String? ?? '').split(',').where((e) => e.isNotEmpty).toList(),
      photo: map['photo'] as String? ?? '',
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      category: map['category'] as String?,
      isPromoted: (map['isPromoted'] as int? ?? 0) == 1,
    );
  }
}