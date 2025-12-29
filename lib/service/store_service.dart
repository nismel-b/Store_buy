
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:store_buy/database/database_helper.dart';
import 'package:store_buy/model/store_model.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class StoreService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create a new store
  Future<Store?> createStore({
    required String userId,
    required String storename,
    required Category category,
    required String description,
    required String slogan,
    //required String regle,
    required String password,
    required String adresse,
    required String photo,
    required String code,
    required String openingTime,
    required String closeTime,
  }) async {
    try {
      final db = await _dbHelper.database;
      final storeId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('stores', {
        'storeId': storeId,
        'userId': userId,
        'storename': storename,
        'category': category.toString().split('.').last,
        'description': description,
        'slogan': slogan,
       // 'regle': regle,
        'password': password,
        'adresse': adresse,
        'photo': photo,
        'code': code,
        'openingTime': openingTime,
        'closeTime': closeTime,
        'createdAt': now,
      });

      return Store(
        storeId: storeId,
        userId: userId,
        storename: storename,
        category: category,
        description: description,
        slogan: slogan,
      //  regle: regle,
        password: password,
        adresse: adresse,
        photo: photo,
        code: code,
        openingTime: null,
        closingTime: null,
        isOpen: true,
      );
    } catch (e) {
      debugPrint('Error creating store: $e');
      return null;
    }
  }

  // Get all stores
  Future<List<Map<String, dynamic>>> getAllStores() async {
    try {
      final db = await _dbHelper.database;
      return await db.query('stores', orderBy: 'createdAt DESC');
    } catch (e) {
      debugPrint('Error getting stores: $e');
      return [];
    }
  }

  // Get stores by category
  Future<List<Map<String, dynamic>>> getStoresByCategory(Category category) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        'stores',
        where: 'category = ?',
        whereArgs: [category.toString().split('.').last],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      debugPrint('Error getting stores by category: $e');
      return [];
    }
  }

  // Get store by ID
  Future<Map<String, dynamic>?> getStoreById(String storeId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'stores',
        where: 'storeId = ?',
        whereArgs: [storeId],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('Error getting store: $e');
      return null;
    }
  }

  // Get stores by user ID
  Future<List<Map<String, dynamic>>> getStoresByUserId(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        'stores',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      debugPrint('Error getting stores by user: $e');
      return [];
    }
  }

  // Update store
  Future<bool> updateStore(String storeId, Map<String, dynamic> updates) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'stores',
        updates,
        where: 'storeId = ?',
        whereArgs: [storeId],
      );
      return true;
    } catch (e) {
      debugPrint('Error updating store: $e');
      return false;
    }
  }

  // Delete store
  Future<bool> deleteStore(String storeId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('stores', where: 'storeId = ?', whereArgs: [storeId]);
      return true;
    } catch (e) {
      debugPrint('Error deleting store: $e');
      return false;
    }
  }
}

