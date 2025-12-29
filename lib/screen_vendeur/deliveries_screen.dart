import 'package:flutter/material.dart';
import 'package:store_buy/service/delivery_service.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DeliveriesScreen extends StatefulWidget {
  final String? storeId;
  const DeliveriesScreen({super.key, this.storeId});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  final StoreService _storeService = StoreService();
  List<Map<String, dynamic>> _deliveries = [];
  String? _selectedStoreId;
  String _filterStatus = 'all';
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
      final deliveries = await _deliveryService.getDeliveriesByStore(_selectedStoreId!);
      setState(() {
        _deliveries = deliveries;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String deliveryId, String status) async {
    String? actualDate;
    if (status == 'delivered') {
      actualDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    }
    await _deliveryService.updateDeliveryStatus(deliveryId, status, actualDate: actualDate);
    _loadData();
  }

  List<Map<String, dynamic>> get _filteredDeliveries {
    if (_filterStatus == 'all') return _deliveries;
    return _deliveries.where((d) => d['status'] == _filterStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_transit':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livraisons'),
        backgroundColor: const Color(0xFF3B82F6),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Toutes'),
                    selected: _filterStatus == 'all',
                    onSelected: (selected) {
                      if (selected) setState(() => _filterStatus = 'all');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('En attente'),
                    selected: _filterStatus == 'pending',
                    onSelected: (selected) {
                      if (selected) setState(() => _filterStatus = 'pending');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Livrées'),
                    selected: _filterStatus == 'delivered',
                    onSelected: (selected) {
                      if (selected) setState(() => _filterStatus = 'delivered');
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
          : _filteredDeliveries.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping, size: 100, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Aucune livraison',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredDeliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = _filteredDeliveries[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(delivery['status']),
                            child: const Icon(Icons.local_shipping, color: Colors.white),
                          ),
                          title: Text(delivery['userName'] ?? 'Client'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Adresse: ${delivery['deliveryAddress']}'),
                              Text('Montant: ${delivery['totalAmount']} FCFA'),
                              if (delivery['estimatedDate'] != null)
                                Text('Estimation: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(delivery['estimatedDate']))}'),
                              if (delivery['actualDate'] != null)
                                Text('Livré le: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(delivery['actualDate']))}'),
                              Chip(
                                label: Text(delivery['status']),
                                backgroundColor: _getStatusColor(delivery['status']),
                              ),
                            ],
                          ),
                          trailing: delivery['status'] == 'pending'
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _updateStatus(
                                        delivery['deliveryId'],
                                        'in_transit',
                                      ),
                                      child: const Text('En transit'),
                                    ),
                                    const SizedBox(height: 5),
                                    ElevatedButton(
                                      onPressed: () => _updateStatus(
                                        delivery['deliveryId'],
                                        'delivered',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text('Livré'),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}


