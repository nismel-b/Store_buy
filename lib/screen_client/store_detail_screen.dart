import 'package:flutter/material.dart';
import 'package:store_buy/model/store_model.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/service/product_service.dart';
import 'package:store_buy/service/store_review_service.dart';
import 'package:store_buy/service/favorite_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:store_buy/model/product_model.dart';
import 'package:store_buy/screen_client/product_detail_screen.dart';
import 'package:store_buy/screen_client/report_screen.dart';
import 'package:store_buy/service/share_service.dart';
import 'package:store_buy/widgets/store_status_banner.dart';
import 'package:store_buy/constants/app_colors.dart';
import 'package:provider/provider.dart';

class StoreDetailScreen extends StatefulWidget {
  final String storeId;
  const StoreDetailScreen({super.key, required this.storeId});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  final StoreService _storeService = StoreService();
  final ProductService _productService = ProductService();
  final StoreReviewService _reviewService = StoreReviewService();
  final FavoriteService _favoriteService = FavoriteService();
  final ShareService _shareService = ShareService();
  Map<String, dynamic>? _store;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0.0;
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    final store = await _storeService.getStoreById(widget.storeId);
    final products = await _productService.getProductsByStore(widget.storeId);
    final reviews = await _reviewService.getStoreReviews(widget.storeId);
    final average = await _reviewService.getAverageRating(widget.storeId);

    if(!mounted)return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool isFav = false;
    if (authProvider.currentUser != null) {
      isFav = await _favoriteService.isStoreFavorite(
        authProvider.currentUser!.userId,
        widget.storeId,
      );


    }
    
    setState(() {
      _store = store;
      _products = products;
      _reviews = reviews;
      _averageRating = average;
      _isFavorite = isFav;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    if (_isFavorite) {
      await _favoriteService.removeStoreFromFavorites(
        authProvider.currentUser!.userId,
        widget.storeId,
      );
    } else {
      await _favoriteService.addStoreToFavorites(
        userId: authProvider.currentUser!.userId,
        storeId: widget.storeId,
      );
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Magasin')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_store == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Magasin')),
        body: const Center(child: Text('Magasin non trouvé')),
      );
    }

    // Convert store data to Store model
    final storeModel = Store(
      storeId: _store!['storeId'],
      userId: _store!['userId'],
      storename: _store!['storename'] ?? 'Magasin',
      category: Category.values.firstWhere(
        (c) => c.toString().split('.').last == _store!['category'],
        orElse: () => Category.bazar,
      ),
      description: _store!['description'] ?? '',
      slogan: _store!['slogan'] ?? '',
      //regle: _store!['regle'] ?? '',
      password: _store!['password'] ?? '',
      adresse: _store!['adresse'] ?? '',
      photo: _store!['photo'] ?? '',
      code: _store!['code'] ?? '',
      openingTime: _store!['openingTime'],
      closingTime: _store!['closingTime'],
      isOpen: (_store!['isOpen'] as int? ?? 1) == 1,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_store!['storename'] ?? 'Magasin'),
        backgroundColor: const Color(0xFF3B82F6),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: _isFavorite ? Colors.red : Colors.white,
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareService.shareStoreLink(
                storeId: widget.storeId,
                storeName: _store!['storename'] ?? 'Magasin',
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'report') {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (authProvider.currentUser != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportScreen(
                        reportedUserId: _store!['userId'],
                        storeId: widget.storeId,
                      ),
                    ),
                  );
                }
              } else if (value == 'share_facebook') {
                _shareService.shareOnSocialMedia(
                  storeId: widget.storeId,
                  storeName: _store!['storename'] ?? 'Magasin',
                  platform: 'facebook',
                );
              } else if (value == 'share_twitter') {
                _shareService.shareOnSocialMedia(
                  storeId: widget.storeId,
                  storeName: _store!['storename'] ?? 'Magasin',
                  platform: 'twitter',
                );
              } else if (value == 'share_whatsapp') {
                _shareService.shareOnSocialMedia(
                  storeId: widget.storeId,
                  storeName: _store!['storename'] ?? 'Magasin',
                  platform: 'whatsapp',
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'share_facebook', child: Text('Partager sur Facebook')),
              const PopupMenuItem(value: 'share_twitter', child: Text('Partager sur Twitter')),
              const PopupMenuItem(value: 'share_whatsapp', child: Text('Partager sur WhatsApp')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'report', child: Text('Signaler')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store status banner
            StoreStatusBanner(store: storeModel),
            // Store header
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[200],
              child: _store!['photo'] != null && _store!['photo'].toString().isNotEmpty
                  ? Image.network(
                      _store!['photo'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.store, size: 100);
                      },
                    )
                  : const Icon(Icons.store, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _store!['storename'] ?? 'Magasin',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ChettaVissto',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (_store!['slogan'] != null && _store!['slogan'].toString().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      _store!['slogan'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (_store!['description'] != null && _store!['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _store!['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  if (_store!['adresse'] != null && _store!['adresse'].toString().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _store!['adresse'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Rating section
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 5),
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('(${_reviews.length} avis)'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Show reviews dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Avis sur le magasin'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _reviews.length,
                                  itemBuilder: (context, index) {
                                    final review = _reviews[index];
                                    return ListTile(
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
                                      subtitle: review['comment'] != null
                                          ? Text(review['comment'])
                                          : null,
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Fermer'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Voir tous les avis'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Produits',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _products.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text('Aucun produit disponible'),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = Product.fromMap(_products[index]);
                            return GestureDetector(
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
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(15),
                                          ),
                                          color: Colors.grey[200],
                                        ),
                                        child: product.photo.isNotEmpty
                                            ? Image.network(
                                                product.photo,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(Icons.image, size: 50);
                                                },
                                              )
                                            : const Icon(Icons.image, size: 50),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.productName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${product.price} FCFA',
                                            style: const TextStyle(
                                              color: Color(0xFF3B82F6),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
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
          ],
        ),
      ),
    );
  }
}

