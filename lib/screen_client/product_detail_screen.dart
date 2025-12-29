import 'package:flutter/material.dart';
import 'package:store_buy/model/product_model.dart';
import 'package:store_buy/service/product_service.dart';
import 'package:store_buy/providers/cart_provider.dart';
import 'package:store_buy/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:store_buy/screen_client/product_review_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  Map<String, dynamic>? _product;
  bool _isLoading = true;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final product = await _productService.getProductById(widget.productId);
    setState(() {
      _product = product;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails du produit')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails du produit')),
        body: const Center(child: Text('Produit non trouvé')),
      );
    }

    final product = Product.fromMap(_product!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image - Large and clean
            Container(
              height: 350,
              width: double.infinity,
              color: AppColors.lightGrey.withValues(alpha:0.3),
              child: product.photo.isNotEmpty
                  ? Image.network(
                      product.photo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.image_outlined, 
                            size: 80, 
                            color: AppColors.textSecondary.withValues(alpha:0.5)),
                        );
                      },
                    )
                  : Center(
                      child: Icon(Icons.image_outlined, 
                        size: 80, 
                        color: AppColors.textSecondary.withValues(alpha:0.5)),
                    ),
            ),
            // Product details - Clean minimalist layout
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category (if available)
                  if (product.category != null && product.category!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        product.category!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  // Product name
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Price
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    product.characteristic.isNotEmpty 
                        ? product.characteristic 
                        : 'It\'s very easy to create stylish and beautiful prototypes for your future projects or interfaces.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quantity selector - Minimalist style
                  if (product.quantity > 0)
                    Row(
                      children: [
                        const Text(
                          'Quantity: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightGrey),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                color: AppColors.textPrimary,
                                onPressed: _quantity > 1
                                    ? () {
                                        setState(() {
                                          _quantity--;
                                        });
                                      }
                                    : null,
                              ),
                              Container(
                                width: 40,
                                alignment: Alignment.center,
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                color: AppColors.textPrimary,
                                onPressed: _quantity < product.quantity
                                    ? () {
                                        setState(() {
                                          _quantity++;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  // Buy Now button - Primary action
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: product.quantity > 0
                          ? () {
                              cartProvider.addToCart(product, quantity: _quantity);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Product added to cart'),
                                  backgroundColor: AppColors.primary,
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reviews button - Secondary action
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductReviewScreen(
                              productId: widget.productId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star_outline, size: 20),
                      label: const Text('View Reviews'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: AppColors.lightGrey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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

