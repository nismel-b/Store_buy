import 'package:flutter/material.dart';
import 'package:store_buy/service/order_service.dart';
import 'package:store_buy/model/commande.dart';
import 'package:intl/intl.dart';

class CommandeScreen extends StatefulWidget {
  final String? storeId;
  const CommandeScreen({super.key, this.storeId});

  @override
  State<CommandeScreen> createState() => _CommandeScreenState();
}

class _CommandeScreenState extends State<CommandeScreen> {
  final OrderService _orderService = OrderService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    if (widget.storeId != null) {
      _loadOrders();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOrders() async {
    if (widget.storeId == null) return;
    setState(() => _isLoading = true);
    final orders = await _orderService.getOrdersByStore(widget.storeId!);
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Future<void> _updateOrderStatus(String orderId, EtatCommande newStatus) async {
    final success = await _orderService.updateOrderStatus(orderId, newStatus);
    if (success) {
      _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statut de la commande mis à jour'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_filterStatus == 'all') return _orders;
    return _orders.where((order) => order['status'] == _filterStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'encours':
        return Colors.orange;
      case 'approuved':
        return Colors.blue;
      case 'termine':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'encours':
        return 'En cours';
      case 'approuved':
        return 'Approuvée';
      case 'termine':
        return 'Terminée';
      case 'rejected':
        return 'Rejetée';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.storeId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Aucun magasin sélectionné'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes'),
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
                      if (selected) {
                        setState(() => _filterStatus = 'all');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('En cours'),
                    selected: _filterStatus == 'encours',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _filterStatus = 'encours');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Terminées'),
                    selected: _filterStatus == 'termine',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _filterStatus = 'termine');
                      }
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
          : _filteredOrders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Aucune commande',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(order['status']),
                            child: const Icon(Icons.shopping_bag, color: Colors.white),
                          ),
                          title: Text(
                            order['userName'] ?? 'Client',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${order['totalAmount']} FCFA'),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(
                                  DateTime.parse(order['createdAt']),
                                ),
                              ),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(_getStatusText(order['status'])),
                            backgroundColor: _getStatusColor(order['status']),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (order['deliveryAddress'] != null)
                                    Text('Adresse: ${order['deliveryAddress']}'),
                                  if (order['paymentMethod'] != null)
                                    Text('Paiement: ${order['paymentMethod']}'),
                                  const SizedBox(height: 10),
                                  if (order['status'] == 'encours')
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _updateOrderStatus(
                                              order['orderId'],
                                              EtatCommande.approuved,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                          ),
                                          child: const Text('Approuver'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _updateOrderStatus(
                                              order['orderId'],
                                              EtatCommande.rejected,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Rejeter'),
                                        ),
                                      ],
                                    ),
                                  if (order['status'] == 'approuved')
                                    ElevatedButton(
                                      onPressed: () {
                                        _updateOrderStatus(
                                          order['orderId'],
                                          EtatCommande.termine,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text('Marquer comme terminée'),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
