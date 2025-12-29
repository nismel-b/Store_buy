
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:store_buy/model/product_model.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Service pour gérer les produits
/// Permet d'ajouter, modifier, supprimer et rechercher des produits
class ProductService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Ajouter un nouveau produit au magasin
  /// Retourne le produit créé ou null en cas d'erreur
  Future<Product?> addProduct({
    required String storeId,
    required String productName,
    required String characteristic,
    required List<String> color,
    required String photo,
    required double price,
    required int quantity,
    String? category,
  }) async {
    try {
      final db = await _dbHelper.database;
      final productId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('products', {
        'productId': productId,
        'storeId': storeId,
        'productName': productName,
        'characteristic': characteristic,
        'color': color.join(','),
        'photo': photo,
        'price': price,
        'quantity': quantity,
        'category': category ?? '',
        'isPromoted': 0,
        'createdAt': now,
      });

      return Product(
        productId: productId,
        storeId: storeId,
        productName: productName,
        characteristic: characteristic,
        color: color,
        photo: photo,
        price: price,
        quantity: quantity,
        category: category,
        isPromoted: false,
      );
    } catch (e) {
      debugPrint('Error adding product: $e');
      return null;
    }
  }

  /// Obtenir tous les produits de tous les magasins
  /// Retourne une liste de produits triés par date de création
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final db = await _dbHelper.database;
      return await db.query('products', orderBy: 'createdAt DESC');
    } catch (e) {
      debugPrint('Error getting products: $e');
      return [];
    }
  }

  /// Obtenir tous les produits d'un magasin spécifique
  /// [storeId] : L'identifiant du magasin
  Future<List<Map<String, dynamic>>> getProductsByStore(String storeId) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        'products',
        where: 'storeId = ?',
        whereArgs: [storeId],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      debugPrint('Error getting products by store: $e');
      return [];
    }
  }

  // Get product by ID
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'products',
        where: 'productId = ?',
        whereArgs: [productId],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('Error getting product: $e');
      return null;
    }
  }

  /// Rechercher des produits par nom ou caractéristiques
  /// [query] : Le terme de recherche
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        'products',
        where: 'productName LIKE ? OR characteristic LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  /// Mettre à jour un produit existant
  /// [productId] : L'identifiant du produit
  /// [updates] : Les champs à mettre à jour
  Future<bool> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'products',
        updates,
        where: 'productId = ?',
        whereArgs: [productId],
      );
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  /// Supprimer un produit
  /// [productId] : L'identifiant du produit à supprimer
  Future<bool> deleteProduct(String productId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('products', where: 'productId = ?', whereArgs: [productId]);
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    }
  }

  /// Obtenir les produits les plus vendus d'un magasin
  /// [storeId] : L'identifiant du magasin
  /// Retourne les 10 produits les plus vendus
  Future<List<Map<String, dynamic>>> getBestSellingProducts(String storeId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT p.*, SUM(oi.quantity) as totalSold
        FROM products p
        LEFT JOIN order_items oi ON p.productId = oi.productId
        WHERE p.storeId = ?
        GROUP BY p.productId
        ORDER BY totalSold DESC
        LIMIT 10
      ''', [storeId]);
    } catch (e) {
      debugPrint('Error getting best selling products: $e');
      return [];
    }
  }
}

