import 'package:flutter/material.dart';
import 'package:store_buy/service/review_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:provider/provider.dart';

class ReviewsScreen extends StatefulWidget {
  final String? storeId;
  const ReviewsScreen({super.key, this.storeId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ReviewService _reviewService = ReviewService();
  final StoreService _storeService = StoreService();
  List<Map<String, dynamic>> _reviews = [];
  String? _selectedStoreId;
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
      final reviews = await _reviewService.getReviewsByStore(_selectedStoreId!);
      setState(() {
        _reviews = reviews;
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
        title: const Text('Avis clients'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_outline, size: 100, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Aucun avis pour le moment',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              (review['userName'] as String? ?? 'U')[0].toUpperCase(),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(review['userName'] ?? 'Client'),
                              const SizedBox(width: 10),
                              ...List.generate(5, (i) {
                                return Icon(
                                  i < (review['rating'] as int? ?? 0)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (review['productName'] != null)
                                Text(
                                  'Produit: ${review['productName']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              if (review['comment'] != null && review['comment'].toString().isNotEmpty)
                                Text(review['comment']),
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


