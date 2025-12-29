import 'package:flutter/material.dart';
import 'package:store_buy/service/review_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// Écran pour voir et laisser des avis sur un produit
class ProductReviewScreen extends StatefulWidget {
  final String productId;
  const ProductReviewScreen({super.key, required this.productId});

  @override
  State<ProductReviewScreen> createState() => _ProductReviewScreenState();
}

class _ProductReviewScreenState extends State<ProductReviewScreen> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _reviews = [];
  int _selectedRating = 5;
  bool _isLoading = true;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    final reviews = await _reviewService.getReviewsByProduct(widget.productId);
    final average = await _reviewService.getAverageRating(widget.productId);
    setState(() {
      _reviews = reviews;
      _averageRating = average;
      _isLoading = false;
    });
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un commentaire')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      await _reviewService.addReview(
        userId: authProvider.currentUser!.userId,
        productId: widget.productId,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );
      _commentController.clear();
      _loadReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avis ajouté avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avis'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Average rating
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            _averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return Icon(
                                index < _averageRating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 30,
                              );
                            }),
                          ),
                          Text('${_reviews.length} avis'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add review form
                  const Text(
                    'Laisser un avis',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: _commentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Votre avis',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Publier'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Reviews list
                  const Text(
                    'Tous les avis',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _reviews.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text('Aucun avis pour le moment'),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                                    Text(review['userName'] ?? 'Utilisateur'),
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
                                    if (review['comment'] != null)
                                      Text(review['comment']),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(
                                        DateTime.parse(review['createdAt']),
                                      ),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
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
}


