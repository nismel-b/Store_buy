enum EtatCommande{
  termine,
  approuved,
  encours,
  rejected,
}

class Command{
  final String? orderId;
  final String userId;
  final String storeId;
  final double totalAmount;
  final EtatCommande status;
  final String deliveryAddress;
  final String paymentMethod;
  final DateTime createdAt;
  final List<OrderItem>? items;

  Command({
    this.orderId,
    required this.userId,
    required this.storeId,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'storeId': storeId,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Command.fromMap(Map<String, dynamic> map) {
    return Command(
      orderId: map['orderId'] as String?,
      userId: map['userId'] as String,
      storeId: map['storeId'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      status: EtatCommande.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => EtatCommande.encours,
      ),
      deliveryAddress: map['deliveryAddress'] as String,
      paymentMethod: map['paymentMethod'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class OrderItem {
  final String? orderItemId;
  final String productId;
  final int quantity;
  final double price;
  final String? productName;
  final String? productPhoto;

  OrderItem({
    this.orderItemId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.productName,
    this.productPhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderItemId': orderItemId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}