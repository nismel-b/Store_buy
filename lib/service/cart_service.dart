
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class CartService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add item to cart
  Future<bool> addToCart({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final db = await _dbHelper.database;
      
      // Check if item already exists in cart
      final existing = await db.query(
        'cart',
        where: 'userId = ? AND productId = ?',
        whereArgs: [userId, productId],
      );

      if (existing.isNotEmpty) {
        // Update quantity
        await db.update(
          'cart',
          {'quantity': (existing.first['quantity'] as int) + quantity},
          where: 'userId = ? AND productId = ?',
          whereArgs: [userId, productId],
        );
      } else {
        // Add new item
        final cartId = const Uuid().v4();
        final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        await db.insert('cart', {
          'cartId': cartId,
          'userId': userId,
          'productId': productId,
          'quantity': quantity,
          'createdAt': now,
        });
      }
      return true;
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return false;
    }
  }

  // Get cart items with product details
  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT c.*, p.productName, p.photo, p.price, p.storeId, s.storename
        FROM cart c
        JOIN products p ON c.productId = p.productId
        JOIN stores s ON p.storeId = s.storeId
        WHERE c.userId = ?
        ORDER BY c.createdAt DESC
      ''', [userId]);
    } catch (e) {
      debugPrint('Error getting cart items: $e');
      return [];
    }
  }

  // Update cart item quantity
  Future<bool> updateCartItemQuantity({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final db = await _dbHelper.database;
      if (quantity <= 0) {
        await db.delete(
          'cart',
          where: 'userId = ? AND productId = ?',
          whereArgs: [userId, productId],
        );
      } else {
        await db.update(
          'cart',
          {'quantity': quantity},
          where: 'userId = ? AND productId = ?',
          whereArgs: [userId, productId],
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error updating cart item: $e');
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String userId, String productId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'cart',
        where: 'userId = ? AND productId = ?',
        whereArgs: [userId, productId],
      );
      return true;
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      return false;
    }
  }

  // Clear cart
  Future<bool> clearCart(String userId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('cart', where: 'userId = ?', whereArgs: [userId]);
      return true;
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      return false;
    }
  }

  // Get cart total
  Future<double> getCartTotal(String userId) async {
    try {
     // final db = await _dbHelper.database;
      final items = await getCartItems(userId);
      double total = 0;
      for (var item in items) {
        total += (item['price'] as double) * (item['quantity'] as int);
      }
      return total;
    } catch (e) {
      debugPrint('Error getting cart total: $e');
      return 0.0;
    }
  }

  // Get cart item count
  Future<int> getCartItemCount(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cart WHERE userId = ?',
        [userId],
      );
      return result.isNotEmpty 
          ? (result.first['count'] as int?) ?? 0
          : 0;
    } catch (e) {
      debugPrint('Error getting cart count: $e');
      return 0;
    }
  }
}

