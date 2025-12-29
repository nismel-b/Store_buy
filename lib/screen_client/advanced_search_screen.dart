import 'package:flutter/material.dart';
import 'package:store_buy/service/product_service.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/model/product_model.dart';
import 'package:store_buy/model/store_model.dart';
import 'package:store_buy/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:store_buy/screen_client/product_detail_screen.dart';
import 'package:store_buy/screen_client/store_detail_screen.dart';

/// Écran de recherche avancée avec filtres multiples
class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  final StoreService _storeService = StoreService();
  
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _stores = [];
  bool _isLoading = false;
  String _searchType = 'products'; // 'products' or 'stores'
  
  // Filters
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  bool _inStockOnly = false;
  String _sortBy = 'relevance'; // 'relevance', 'price', 'rating', 'name'

  final List<Map<String, dynamic>> _categories = [
    {'value': Category.freshProduct, 'label': 'Produit frais'},
    {'value': Category.cosmetique, 'label': 'Cosmétique'},
    {'value': Category.accessoire, 'label': 'Accessoire'},
    {'value': Category.electromenager, 'label': 'Électroménager'},
    {'value': Category.bazar, 'label': 'Bazar'},
    {'value': Category.vetementTextile, 'label': 'Vêtements'},
    {'value': Category.materielScolaire, 'label': 'Matériel scolaire'},
    {'value': Category.ustensile, 'label': 'Ustensile de cuisine'},
    {'value': Category.meche, 'label': 'Coiffure et mèche'},
    {'value': Category.shoes, 'label': 'Chaussures'},
    {'value': Category.bijoux, 'label': 'Bijoux'},
    {'value': Category.construction, 'label': 'Matériaux de construction'},
    {'value': Category.hygiene, 'label': 'Produit d\'hygiène'},
    {'value': Category.luminaire, 'label': 'Luminaire'},
    {'value': Category.literieMeuble, 'label': 'Literie et meuble'},
    {'value': Category.restauration, 'label': 'Restauration'},
  ];

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un mot-clé')),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (_searchType == 'products') {
      final products = await _productService.searchProducts(_searchController.text.trim());
      // Apply filters
      var filtered = products.where((p) {
        if (_inStockOnly && (p['quantity'] as int) == 0) return false;
        if (_minPrice != null && (p['price'] as num) < _minPrice!) return false;
        if (_maxPrice != null && (p['price'] as num) > _maxPrice!) return false;
        return true;
      }).toList();

      // Sort
      filtered.sort((a, b) {
        switch (_sortBy) {
          case 'price':
            return (a['price'] as num).compareTo(b['price'] as num);
          case 'name':
            return (a['productName'] as String).compareTo(b['productName'] as String);
          default:
            return 0; // relevance (already sorted by search)
        }
      });

      setState(() {
        _products = filtered;
        _isLoading = false;
      });
    } else {
      final stores = await _storeService.getAllStores();
      // Filter stores
      var filtered = stores.where((s) {
        if (_selectedCategory != null) {
          return s['category'] == _selectedCategory;
        }
        return s['storename'].toString().toLowerCase().contains(
          _searchController.text.trim().toLowerCase(),
        );
      }).toList();

      setState(() {
        _stores = filtered;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche avancée'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _products = [];
                          _stores = [];
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Produits'),
                        selected: _searchType == 'products',
                        onSelected: (selected) {
                          if (selected) setState(() => _searchType = 'products');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Magasins'),
                        selected: _searchType == 'stores',
                        onSelected: (selected) {
                          if (selected) setState(() => _searchType = 'stores');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Rechercher'),
                ),
              ],
            ),
          ),
          // Filters
          Expanded(
            child: Row(
              children: [
                // Filters panel
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Filtres',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      if (_searchType == 'products') ...[
                        const Text('Prix min'),
                        TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _minPrice = double.tryParse(value);
                          },
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text('Prix max'),
                        TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _maxPrice = double.tryParse(value);
                          },
                          decoration: const InputDecoration(
                            hintText: '100000',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CheckboxListTile(
                          title: const Text('En stock uniquement'),
                          value: _inStockOnly,
                          onChanged: (value) {
                            setState(() => _inStockOnly = value ?? false);
                          },
                        ),
                      ],
                      if (_searchType == 'stores') ...[
                        const Text('Catégorie'),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat['value'].toString().split('.').last,
                              child: Text(cat['label']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCategory = value);
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Text('Trier par'),
                      RadioListTile<String>(
                        title: const Text('Pertinence'),
                        value: 'relevance',
                        groupValue: _sortBy,
                        onChanged: (value) => setState(() => _sortBy = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('Prix'),
                        value: 'price',
                        groupValue: _sortBy,
                        onChanged: (value) => setState(() => _sortBy = value!),
                      ),
                      RadioListTile<String>(
                        title: const Text('Nom'),
                        value: 'name',
                        groupValue: _sortBy,
                        onChanged: (value) => setState(() => _sortBy = value!),
                      ),
                    ],
                  ),
                ),
                // Results
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _searchType == 'products'
                          ? _buildProductsList()
                          : _buildStoresList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (_products.isEmpty) {
      return const Center(
        child: Text('Aucun résultat'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = Product.fromMap(_products[index]);
        final cartProvider = Provider.of<CartProvider>(context);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: product.photo.isNotEmpty
                ? Image.network(
                    product.photo,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, size: 60);
                    },
                  )
                : const Icon(Icons.image, size: 60),
            title: Text(product.productName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${product.price} FCFA'),
                Text('Stock: ${product.quantity}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                cartProvider.addToCart(product);
              },
            ),
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
          ),
        );
      },
    );
  }

  Widget _buildStoresList() {
    if (_stores.isEmpty) {
      return const Center(
        child: Text('Aucun résultat'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stores.length,
      itemBuilder: (context, index) {
        final store = _stores[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: store['photo'] != null && store['photo'].toString().isNotEmpty
                ? Image.network(
                    store['photo'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.store, size: 60);
                    },
                  )
                : const Icon(Icons.store, size: 60),
            title: Text(store['storename'] ?? 'Magasin'),
            subtitle: Text(store['category'] ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoreDetailScreen(
                    storeId: store['storeId'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}


