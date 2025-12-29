import 'package:flutter/material.dart';
import 'package:store_buy/service/favorite_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:store_buy/model/product_model.dart';
import 'package:store_buy/constants/app_colors.dart';
import 'package:provider/provider.dart';


/// Écran pour afficher les magasins et produits favoris
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  final FavoriteService _favoriteService = FavoriteService();
  late TabController _tabController;
  List<Map<String, dynamic>> _favoriteStores = [];
  List<Map<String, dynamic>> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final stores = await _favoriteService.getFavoriteStores(authProvider.currentUser!.userId);
      final products = await _favoriteService.getFavoriteProducts(authProvider.currentUser!.userId);
      setState(() {
        _favoriteStores = stores;
        _favoriteProducts = products;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeStoreFavorite(String storeId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      await _favoriteService.removeStoreFromFavorites(
        authProvider.currentUser!.userId,
        storeId,
      );
      _loadFavorites();
    }
  }

  Future<void> _removeProductFavorite(String productId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      await _favoriteService.removeProductFromFavorites(
        authProvider.currentUser!.userId,
        productId,
      );
      _loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
        backgroundColor: AppColors.primaryDark,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Magasins',),
            Tab(text: 'Produits',),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Stores tab
                _favoriteStores.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store_outlined, size: 100, color: Colors.grey),
                            SizedBox(height: 20),
                            Text(
                              'Aucun magasin favori',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFavorites,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _favoriteStores.length,
                          itemBuilder: (context, index) {
                            final store = _favoriteStores[index];
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
                                    right: 5,
                                    child: IconButton(
                                      icon: const Icon(Icons.favorite, color: Colors.red),
                                      onPressed: () => _removeStoreFavorite(store['storeId']),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                // Products tab
                _favoriteProducts.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, size: 100, color: Colors.grey),
                            SizedBox(height: 20),
                            Text(
                              'Aucun produit favori',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFavorites,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _favoriteProducts.length,
                          itemBuilder: (context, index) {
                            final product = Product.fromMap(_favoriteProducts[index]);
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
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${product.price} FCFA',
                                              style: const TextStyle(
                                                color: Color(0xFF3B82F6),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: IconButton(
                                      icon: const Icon(Icons.favorite, color: Colors.red),
                                      onPressed: () => _removeProductFavorite(product.productId!),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}

