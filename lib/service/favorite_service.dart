
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Service pour gérer les favoris (magasins et produits)
class FavoriteService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Ajouter un magasin aux favoris
  Future<bool> addStoreToFavorites({
    required String userId,
    required String storeId,
  }) async {
    try {
      final db = await _dbHelper.database;
      final favoriteId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('store_favorites', {
        'favoriteId': favoriteId,
        'userId': userId,
        'storeId': storeId,
        'createdAt': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error adding store to favorites: $e');
      return false;
    }
  }

  /// Retirer un magasin des favoris
  Future<bool> removeStoreFromFavorites(String userId, String storeId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'store_favorites',
        where: 'userId = ? AND storeId = ?',
        whereArgs: [userId, storeId],
      );
      return true;
    } catch (e) {
      debugPrint('Error removing store from favorites: $e');
      return false;
    }
  }

  /// Vérifier si un magasin est en favoris
  Future<bool> isStoreFavorite(String userId, String storeId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'store_favorites',
        where: 'userId = ? AND storeId = ?',
        whereArgs: [userId, storeId],
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking favorite: $e');
      return false;
    }
  }

  /// Obtenir tous les magasins favoris
  Future<List<Map<String, dynamic>>> getFavoriteStores(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT s.*, sf.createdAt as favoritedAt
        FROM store_favorites sf
        JOIN stores s ON sf.storeId = s.storeId
        WHERE sf.userId = ?
        ORDER BY sf.createdAt DESC
      ''', [userId]);
    } catch (e) {
      debugPrint('Error getting favorite stores: $e');
      return [];
    }
  }

  /// Ajouter un produit aux favoris
  Future<bool> addProductToFavorites({
    required String userId,
    required String productId,
  }) async {
    try {
      final db = await _dbHelper.database;
      final favoriteId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('favorites', {
        'favoriteId': favoriteId,
        'userId': userId,
        'productId': productId,
        'createdAt': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error adding product to favorites: $e');
      return false;
    }
  }

  /// Retirer un produit des favoris
  Future<bool> removeProductFromFavorites(String userId, String productId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'favorites',
        where: 'userId = ? AND productId = ?',
        whereArgs: [userId, productId],
      );
      return true;
    } catch (e) {
      debugPrint('Error removing product from favorites: $e');
      return false;
    }
  }

  /// Obtenir tous les produits favoris
  Future<List<Map<String, dynamic>>> getFavoriteProducts(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT p.*, f.createdAt as favoritedAt
        FROM favorites f
        JOIN products p ON f.productId = p.productId
        WHERE f.userId = ?
        ORDER BY f.createdAt DESC
      ''', [userId]);
    } catch (e) {
      debugPrint('Error getting favorite products: $e');
      return [];
    }
  }
}


