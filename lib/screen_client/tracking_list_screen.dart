import 'package:flutter/material.dart';
import 'package:store_buy/service/purchase_tracking_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:store_buy/model/product_model.dart';
import 'package:provider/provider.dart';
import 'package:store_buy/screen_client/product_detail_screen.dart';

/// Écran pour gérer la liste de suivi des achats (liste d'attente)
class TrackingListScreen extends StatefulWidget {
  const TrackingListScreen({super.key});

  @override
  State<TrackingListScreen> createState() => _TrackingListScreenState();
}

class _TrackingListScreenState extends State<TrackingListScreen> {
  final PurchaseTrackingService _trackingService = PurchaseTrackingService();
  List<Map<String, dynamic>> _trackingList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrackingList();
  }

  Future<void> _loadTrackingList() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final list = await _trackingService.getTrackingList(authProvider.currentUser!.userId);
      setState(() {
        _trackingList = list;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePriority(String trackingId, int newPriority) async {
    await _trackingService.updatePriority(trackingId, newPriority);
    _loadTrackingList();
  }

  Future<void> _removeFromList(String trackingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer de la liste'),
        content: const Text('Êtes-vous sûr de vouloir retirer ce produit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retirer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _trackingService.removeFromTracking(trackingId);
      _loadTrackingList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste d\'attente'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trackingList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt, size: 100, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Aucun produit dans la liste',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTrackingList,
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _trackingList.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _trackingList.removeAt(oldIndex);
                      _trackingList.insert(newIndex, item);
                      // Update priorities
                      for (int i = 0; i < _trackingList.length; i++) {
                        _updatePriority(
                          _trackingList[i]['trackingId'],
                          _trackingList.length - i,
                        );
                      }
                    },
                    itemBuilder: (context, index) {
                      final item = _trackingList[index];
                      final product = Product.fromMap(item);
                      return Card(
                        key: ValueKey(item['trackingId']),
                        margin: const EdgeInsets.only(bottom: 10),
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
                              Text('${product.price} FCFA'),
                              Text('Priorité: ${item['priority']}'),
                              Text('Stock: ${product.quantity}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_upward),
                                onPressed: () {
                                  _updatePriority(
                                    item['trackingId'],
                                    (item['priority'] as int) + 1,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeFromList(item['trackingId']),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  productId: product.productId!,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}


