import 'package:flutter/material.dart';
import 'package:store_buy/service/story_service.dart';
import 'package:store_buy/service/story_comment_service.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/service/product_service.dart';
import 'package:store_buy/model/product_model.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:store_buy/providers/cart_provider.dart';
import 'package:provider/provider.dart';


/// Écran pour voir les stories et laisser des commentaires
class StoriesViewScreen extends StatefulWidget {
  final String? storeId;
  const StoriesViewScreen({super.key, this.storeId});

  @override
  State<StoriesViewScreen> createState() => _StoriesViewScreenState();
}

class _StoriesViewScreenState extends State<StoriesViewScreen> {
  final StoryService _storyService = StoryService();
  final StoryCommentService _commentService = StoryCommentService();
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _stories = [];
  Map<String, dynamic>? _selectedStory;
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _showComments = false;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadStories() async {
    if (widget.storeId != null) {
      final stories = await _storyService.getActiveStoriesByStore(widget.storeId!);
      setState(() {
        _stories = stories;
        _isLoading = false;
      });
    } else {
      final storeService = StoreService();
      final stores = await storeService.getAllStores();
      final allStories = <Map<String, dynamic>>[];
      for (var store in stores) {
        final stories = await _storyService.getActiveStoriesByStore(store['storeId']);
        allStories.addAll(stories);
      }
      setState(() {
        _stories = allStories;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadComments(String storyId) async {
    final comments = await _commentService.getStoryComments(storyId);
    setState(() {
      _comments = comments;
      _showComments = true;
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty || _selectedStory == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      await _commentService.addComment(
        storyId: _selectedStory!['storyId'],
        userId: authProvider.currentUser!.userId,
        content: _commentController.text.trim(),
      );
      _commentController.clear();
      _loadComments(_selectedStory!['storyId']);
    }
  }

  Future<void> _buyPromotionProduct() async {
    if (_selectedStory == null || _selectedStory!['productId'] == null) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final productService = ProductService();
    final productData = await productService.getProductById(_selectedStory!['productId']);
    
    if (productData != null) {
      final promoProduct = Product.fromMap(productData);
      // Use promotion price if available
      if (_selectedStory!['promotionPrice'] != null) {
        // Create a modified product with promotion price
        final promoPrice = (_selectedStory!['promotionPrice'] as num).toDouble();
        // Note: In a real app, you'd need to handle promotion prices differently
        await cartProvider.addToCart(promoProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produit ajouté au panier : $promoPrice FCFA'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await cartProvider.addToCart(promoProduct);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stories.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_stories, size: 100, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Aucune story disponible',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : PageView.builder(
                  itemCount: _stories.length,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedStory = _stories[index];
                      _showComments = false;
                      _comments = [];
                    });
                    if (_selectedStory != null) {
                      _loadComments(_selectedStory!['storyId']);
                    }
                  },
                  itemBuilder: (context, index) {
                    final story = _stories[index];
                    if (index == 0 && _selectedStory == null) {
                      _selectedStory = story;
                      _loadComments(story['storyId']);
                    }
                    return _buildStoryView(story);
                  },
                ),
    );
  }

  Widget _buildStoryView(Map<String, dynamic> story) {
    return Stack(
      children: [
        // Story image
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: story['imageUrl'] != null && story['imageUrl'].toString().isNotEmpty
              ? Image.network(
                  story['imageUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey);
                  },
                )
              : Container(color: Colors.grey),
        ),
        // Content overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (story['title'] != null)
                  Text(
                    story['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (story['description'] != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    story['description'],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
                if (story['type'] == 'promotion' && story['promotionPrice'] != null) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        '${story['promotionPrice']} FCFA',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _buyPromotionProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Acheter'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                // Comments section
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.white),
                      onPressed: () {
                        setState(() => _showComments = !_showComments);
                      },
                    ),
                    Text(
                      '${_comments.length} commentaires',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                if (_showComments) ...[
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            child: Text(
                              (comment['userName'] as String? ?? 'U')[0].toUpperCase(),
                            ),
                          ),
                          title: Text(
                            comment['userName'] ?? 'Utilisateur',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          subtitle: Text(
                            comment['content'],
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Ajouter un commentaire...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _addComment,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

