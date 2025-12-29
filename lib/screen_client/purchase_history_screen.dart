import 'package:flutter/material.dart';
import 'package:store_buy/service/purchase_history_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// Écran pour afficher l'historique des achats
class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final PurchaseHistoryService _historyService = PurchaseHistoryService();
  List<Map<String, dynamic>> _purchases = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final purchases = await _historyService.getPurchaseHistory(
        authProvider.currentUser!.userId,
      );
      final stats = await _historyService.getPurchaseStats(
        authProvider.currentUser!.userId,
      );
      setState(() {
        _purchases = purchases;
        _stats = stats;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des achats'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_stats != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Achats',
                          '${_stats!['totalPurchases'] ?? 0}',
                          Icons.shopping_bag,
                        ),
                        _buildStatItem(
                          'Total',
                          '${(_stats!['totalSpent'] ?? 0.0).toStringAsFixed(0)} FCFA',
                          Icons.attach_money,
                        ),
                        _buildStatItem(
                          'Moyenne',
                          '${(_stats!['averagePurchase'] ?? 0.0).toStringAsFixed(0)} FCFA',
                          Icons.trending_up,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _purchases.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 100, color: Colors.grey),
                              SizedBox(height: 20),
                              Text(
                                'Aucun achat',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _purchases.length,
                            itemBuilder: (context, index) {
                              final purchase = _purchases[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    child: const Icon(Icons.shopping_bag, color: Colors.white),
                                  ),
                                  title: Text(purchase['storename'] ?? 'Magasin'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${purchase['totalAmount']} FCFA'),
                                      Text('Statut: ${purchase['status']}'),
                                      Text(
                                        DateFormat('dd/MM/yyyy HH:mm').format(
                                          DateTime.parse(purchase['purchaseDate']),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF3B82F6)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}


