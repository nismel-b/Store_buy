import 'package:flutter/material.dart';
import 'package:store_buy/service/reservation_service.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReservationsScreen extends StatefulWidget {
  final String? storeId;
  const ReservationsScreen({super.key, this.storeId});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  final StoreService _storeService = StoreService();
  List<Map<String, dynamic>> _reservations = [];
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
      final reservations = await _reservationService.getReservationsByStore(_selectedStoreId!);
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String reservationId, String status) async {
    await _reservationService.updateReservationStatus(reservationId, status);
    _loadData();
  }

  List<Map<String, dynamic>> get _filteredReservations {
    if (_filterStatus == 'all') return _reservations;
    return _reservations.where((r) => r['status'] == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservations'),
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
                    label: const Text('Confirmées'),
                    selected: _filterStatus == 'confirmed',
                    onSelected: (selected) {
                      if (selected) setState(() => _filterStatus = 'confirmed');
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
          : _filteredReservations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available, size: 100, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Aucune réservation',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredReservations.length,
                    itemBuilder: (context, index) {
                      final reservation = _filteredReservations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: reservation['type'] == 'delivery'
                                ? Colors.blue
                                : Colors.green,
                            child: Icon(
                              reservation['type'] == 'delivery'
                                  ? Icons.delivery_dining
                                  : Icons.store,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(reservation['userName'] ?? 'Client'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Type: ${reservation['type'] == 'delivery' ? 'Livraison' : 'Retrait'}'),
                              Text('Montant: ${reservation['totalAmount']} FCFA'),
                              if (reservation['pickupDate'] != null)
                                Text('Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(reservation['pickupDate']))}'),
                              Text('Statut: ${reservation['status']}'),
                            ],
                          ),
                          trailing: reservation['status'] == 'pending'
                              ? ElevatedButton(
                                  onPressed: () => _updateStatus(
                                    reservation['reservationId'],
                                    'confirmed',
                                  ),
                                  child: const Text('Confirmer'),
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


