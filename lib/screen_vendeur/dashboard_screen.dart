import 'package:flutter/material.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/service/order_service.dart';
import 'package:store_buy/service/product_service.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  final String? storeId;
  const DashboardScreen({super.key, this.storeId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StoreService _storeService = StoreService();
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();
  Map<String, dynamic>? _statistics;
  List<Map<String, dynamic>> _bestSelling = [];
  bool _isLoading = true;
  String? _selectedStoreId;

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
      await _loadStatistics();
      await _loadBestSelling();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadStatistics() async {
    if (_selectedStoreId == null) return;
    final stats = await _orderService.getOrderStatistics(_selectedStoreId!);
    setState(() {
      _statistics = stats;
    });
  }

  Future<void> _loadBestSelling() async {
    if (_selectedStoreId == null) return;
    final products = await _productService.getBestSellingProducts(_selectedStoreId!);
    setState(() {
      _bestSelling = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedStoreId == null) {
      return const Center(
        child: Text('Aucun magasin trouvé'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Statistics cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Commandes',
                    '${_statistics?['totalOrders'] ?? 0}',
                    Icons.shopping_bag,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Ventes',
                    '${(_statistics?['totalSales'] ?? 0.0).toStringAsFixed(0)} FCFA',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'En attente',
                    '${_statistics?['pendingOrders'] ?? 0}',
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Produits',
                    '${_bestSelling.length}',
                    Icons.inventory_2,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Produits les plus vendus',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _bestSelling.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('Aucune vente pour le moment'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _bestSelling.length,
                    itemBuilder: (context, index) {
                      final product = _bestSelling[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: product['photo'] != null && product['photo'].toString().isNotEmpty
                              ? Image.network(
                                  product['photo'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image, size: 60);
                                  },
                                )
                              : const Icon(Icons.image, size: 60),
                          title: Text(product['productName'] ?? 'Produit'),
                          subtitle: Text('${product['totalSold'] ?? 0} vendus'),
                          trailing: Text(
                            '${product['price']} FCFA',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
