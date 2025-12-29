import 'package:flutter/material.dart';
import 'package:store_buy/service/store_service.dart';


/// Écran pour le live shopping
class LiveShoppingScreen extends StatefulWidget {
  final String? storeId;
  const LiveShoppingScreen({super.key, this.storeId});

  @override
  State<LiveShoppingScreen> createState() => _LiveShoppingScreenState();
}

class _LiveShoppingScreenState extends State<LiveShoppingScreen> {
  final StoreService _storeService = StoreService();
  List<Map<String, dynamic>> _liveStores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLiveStores();
  }

  Future<void> _loadLiveStores() async {
    // In a real app, this would fetch stores that are currently live
    final stores = await _storeService.getAllStores();
    setState(() {
      _liveStores = stores; // For demo, show all stores
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Shopping'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _liveStores.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library, size: 100, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Aucun live en cours',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _liveStores.length,
                  itemBuilder: (context, index) {
                    final store = _liveStores[index];
                    return Card(
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                  ),
                                  child: store['photo'] != null && store['photo'].toString().isNotEmpty
                                      ? Image.network(
                                          store['photo'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.store, size: 50);
                                          },
                                        )
                                      : const Icon(Icons.store, size: 50),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store['storename'] ?? 'Magasin',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 5,
                            left: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.fiber_manual_record, size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Start live shopping (for vendors)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fonctionnalité disponible pour les vendeurs'),
            ),
          );
        },
        icon: const Icon(Icons.videocam),
        label: const Text('Démarrer un live'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


