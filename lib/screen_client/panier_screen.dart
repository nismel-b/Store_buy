import 'package:flutter/material.dart';
import 'package:store_buy/model/panier_model.dart';
import 'package:store_buy/providers/cart_provider.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:store_buy/service/order_service.dart';
import 'package:store_buy/service/purchase_history_service.dart';
import 'package:store_buy/service/budget_service.dart';
import 'package:store_buy/service/reservation_service.dart';
import 'package:provider/provider.dart';

class PanierScreen extends StatefulWidget {
  const PanierScreen({super.key});

  @override
  State<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends State<PanierScreen> {
  final OrderService _orderService = OrderService();
  final PurchaseHistoryService _historyService = PurchaseHistoryService();
  final BudgetService _budgetService = BudgetService();
  final ReservationService _reservationService = ReservationService();
  final _addressController = TextEditingController();
  String _paymentMethod = 'Carte';
  String _deliveryType = 'delivery'; // 'delivery' or 'pickup'
  bool _isProcessing = false;
 // bool _budgetExceeded = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (cartProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votre panier est vide')),
      );
      return;
    }

    if (_deliveryType == 'delivery' && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une adresse de livraison')),
      );
      return;
    }

    // Check budget
    if (authProvider.currentUser != null) {
      final exceeded = await _budgetService.isBudgetExceeded(authProvider.currentUser!.userId);
      if (exceeded) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Budget dépassé'),
            content: const Text(
              'Vous avez dépassé votre limite de budget mensuel. Voulez-vous continuer?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continuer'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }
    }

    setState(() => _isProcessing = true);

    // Group items by store
    final itemsByStore = <String, List<CartItem>>{};
    for (var item in cartProvider.cartItems) {
      if (item.storeId != null) {
        itemsByStore.putIfAbsent(item.storeId!, () => []).add(item);
      }
    }

    // Create orders for each store
    for (var entry in itemsByStore.entries) {
      final storeId = entry.key;
      final items = entry.value;
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);

      final orderItems = items.map((item) {
        return {
          'productId': item.productId,
          'quantity': item.quantity,
          'price': item.product?.price ?? 0,
        };
      }).toList();

      final orderId = await _orderService.createOrder(
        userId: authProvider.currentUser!.userId,
        storeId: storeId,
        totalAmount: totalAmount,
        deliveryAddress: _deliveryType == 'delivery' ? _addressController.text.trim() : 'Retrait en magasin',
        paymentMethod: _paymentMethod,
        items: orderItems,
      );

      // Add to purchase history
      if (orderId != null && authProvider.currentUser != null) {
        await _historyService.addPurchase(
          userId: authProvider.currentUser!.userId,
          orderId: orderId,
          totalAmount: totalAmount,
        );

        // Update budget
        await _budgetService.addExpense(authProvider.currentUser!.userId, totalAmount);

        // Create reservation
        await _reservationService.createReservation(
          orderId: orderId,
          storeId: storeId,
          userId: authProvider.currentUser!.userId,
          type: _deliveryType,
          pickupDate: _deliveryType == 'pickup' ? DateTime.now().add(const Duration(days: 1)).toIso8601String() : null,
        );
      }
    }

    // Clear cart
    await cartProvider.clearCart();

    setState(() => _isProcessing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande passée avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
   // final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: cartProvider.cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Votre panier est vide',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: cartProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.cartItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: item.product?.photo != null && item.product!.photo.isNotEmpty
                              ? Image.network(
                                  item.product!.photo,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image, size: 60);
                                  },
                                )
                              : const Icon(Icons.image, size: 60),
                          title: Text(item.product?.productName ?? 'Produit'),
                          subtitle: Text('${item.product?.price ?? 0} FCFA'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      if (item.quantity > 1) {
                                        cartProvider.updateQuantity(
                                          item.productId,
                                          item.quantity - 1,
                                        );
                                      } else {
                                        cartProvider.removeFromCart(item.productId);
                                      }
                                    },
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      cartProvider.updateQuantity(
                                        item.productId,
                                        item.quantity + 1,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                '${item.totalPrice.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Checkout section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Type de commande',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      RadioListTile<String>(
                        title: const Text('Livraison'),
                        value: 'delivery',
                        groupValue: _deliveryType,
                        onChanged: (value) {
                          setState(() => _deliveryType = value!);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Retrait en magasin'),
                        value: 'pickup',
                        groupValue: _deliveryType,
                        onChanged: (value) {
                          setState(() => _deliveryType = value!);
                        },
                      ),
                      if (_deliveryType == 'delivery') ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Adresse de livraison',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Text('Méthode de paiement:'),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Carte',
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                          ),
                          const Text('Carte'),
                          Radio<String>(
                            value: 'Orange Money',
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                          ),
                          const Text('Orange Money'),
                          Radio<String>(
                            value: 'MTN Mobile Money',
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                          ),
                          const Text('MTN'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${cartProvider.totalAmount.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _checkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isProcessing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Passer la commande',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
