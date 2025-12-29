import 'package:flutter/material.dart';
import 'package:store_buy/model/product_model.dart';
import 'package:store_buy/constants/app_colors.dart';
import 'package:store_buy/providers/product_provider.dart';
import 'package:store_buy/providers/cart_provider.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:store_buy/service/product_service.dart';
import 'package:provider/provider.dart';
import 'package:store_buy/screen_client/panier_screen.dart';
import 'package:store_buy/screen_client/product_detail_screen.dart';
import 'package:store_buy/screen_client/purchase_history_screen.dart';
import 'package:store_buy/screen_client/message_screen.dart';
import 'package:store_buy/screen_client/stories_view_screen.dart';


class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  final _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        cartProvider.setUserId(authProvider.currentUser!.userId);
      }
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.loadProducts();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final products = await _productService.getAllProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  void _searchProducts(String query) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    if (query.isEmpty) {
      productProvider.clearFilters();
    } else {
      productProvider.searchProducts(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Store Self",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        leading: Builder(
          builder: (context){
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PanierScreen()),
                  );
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.store, size: 48, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    authProvider.currentUser?.name ?? 'Utilisateur',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Mes commandes'),
              onTap: () {
                Navigator.pushNamed(context, '/purchase-history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoris'),
              onTap: () {
                Navigator.pushNamed(context, '/favorites');
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Budget'),
              onTap: () {
                Navigator.pushNamed(context, '/budget');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Liste d\'attente'),
              onTap: () {
                Navigator.pushNamed(context, '/tracking-list');
              },
            ),

            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Recherche avancée'),
              onTap: () {
                Navigator.pushNamed(context, '/advanced-search');
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support client'),
              onTap: () {
                Navigator.pushNamed(context, '/client-support');
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Live Shopping'),
              onTap: () {
                Navigator.pushNamed(context, '/live-shopping');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text("Intégrer un magasin"),
              onTap: () {
                Navigator.pushNamed(context, '/join-store');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Search bar - Minimalist design
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.lightGrey, width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'recherche de produit...',
                                hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha:0.6)),
                                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear, color: AppColors.textSecondary),
                                        onPressed: () {
                                          _searchController.clear();
                                          _searchProducts('');
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onChanged: (value) {
                                setState(() {});
                                _searchProducts(value);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Icon(Icons.filter_list, color: AppColors.primary),
                              onPressed: () {
                                Navigator.pushNamed(context, '/advanced-search');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Products section - Clean minimalist design
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Produits',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (_products.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              // View all products
                            },
                            child: Text(
                              'Tout voir',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: _products.length > 20 ? 20 : _products.length,
                          itemBuilder: (context, index) {
                            final productData = _products[index];
                            final product = Product.fromMap(productData);
                            return _buildProductCard(product, cartProvider);
                          },
                            ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            activeIcon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined, size: 24),
            activeIcon: Icon(Icons.message, size: 24),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined, size: 24),
            activeIcon: Icon(Icons.auto_stories, size: 24),
            label: 'Stories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined, size: 24),
            activeIcon: Icon(Icons.history, size: 24),
            label: 'Historique',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Already on home
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessageScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StoriesViewScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PurchaseHistoryScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, CartProvider cartProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.productId!),
          ),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.lightGrey.withValues(alpha:0.5), width: 1),
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image - Minimalist placeholder style
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  color: AppColors.lightGrey.withValues(alpha:0.3),
                ),
                child: product.photo.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        child: Image.network(
                          product.photo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(Icons.image_outlined, 
                                size: 40, 
                                color: AppColors.textSecondary.withValues(alpha:0.5)),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(Icons.image_outlined, 
                          size: 40, 
                          color: AppColors.textSecondary.withValues(alpha:0.5)),
                      ),
              ),
            ),
            // Product details - Clean minimalist text
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${product.price}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.favorite_border, 
                          size: 20, 
                          color: AppColors.textSecondary),
                        onPressed: () {
                          // Add to favorites
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        cartProvider.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Product added to cart'),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Buy',
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
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
