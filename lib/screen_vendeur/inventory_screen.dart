import 'package:flutter/material.dart';
import 'package:store_buy/service/product_service.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/model/product_model.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class InventoryScreen extends StatefulWidget {
  final String? storeId;
  const InventoryScreen({super.key, this.storeId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ProductService _productService = ProductService();
  final StoreService _storeService = StoreService();
  List<Map<String, dynamic>> _products = [];
  String? _selectedStoreId;
  String _filter = 'all'; // 'all', 'low_stock', 'out_of_stock'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (widget.storeId != null) {
      _selectedStoreId = widget.storeId;
    } else if (authProvider.currentUser != null) {
      final stores = await _storeService.getStoresByUserId(
        authProvider.currentUser!.userId,
      );
      if (stores.isNotEmpty) {
        _selectedStoreId = stores.first['storeId'];
      }
    }

    if (_selectedStoreId != null) {
      final products = await _productService.getProductsByStore(_selectedStoreId!);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStock(String productId, int newQuantity) async {
    await _productService.updateProduct(productId, {'quantity': newQuantity});
    _loadData();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    switch (_filter) {
      case 'low_stock':
        return _products.where((p) => (p['quantity'] as int) < 10 && (p['quantity'] as int) > 0).toList();
      case 'out_of_stock':
        return _products.where((p) => (p['quantity'] as int) == 0).toList();
      default:
        return _products;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des stocks'),
        backgroundColor: const Color(0xFF3B82F6),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Tous'),
                    selected: _filter == 'all',
                    onSelected: (selected) {
                      if (selected) setState(() => _filter = 'all');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Stock faible'),
                    selected: _filter == 'low_stock',
                    onSelected: (selected) {
                      if (selected) setState(() => _filter = 'low_stock');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Rupture'),
                    selected: _filter == 'out_of_stock',
                    onSelected: (selected) {
                      if (selected) setState(() => _filter = 'out_of_stock');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredProducts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Aucun produit',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = Product.fromMap(_filteredProducts[index]);
                      final isLowStock = product.quantity < 10 && product.quantity > 0;
                      final isOutOfStock = product.quantity == 0;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: isOutOfStock
                            ? Colors.red[50]
                            : isLowStock
                                ? Colors.orange[50]
                                : null,
                        child: ListTile(
                          leading: product.photo.isNotEmpty
                              ? Image.network(
                                  product.photo,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image, size: 60);
                                  },
                                )
                              : const Icon(Icons.image, size: 60),
                          title: Text(product.productName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Stock actuel: ${product.quantity}'),
                              if (isOutOfStock)
                                const Text(
                                  'RUPTURE DE STOCK',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else if (isLowStock)
                                const Text(
                                  'STOCK FAIBLE',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  if (product.quantity > 0) {
                                    _updateStock(product.productId!, product.quantity - 1);
                                  }
                                },
                              ),
                              Text('${product.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                onPressed: () {
                                  _updateStock(product.productId!, product.quantity + 1);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}


