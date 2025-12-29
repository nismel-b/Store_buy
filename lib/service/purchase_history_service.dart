
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Service pour gérer l'historique des achats
class PurchaseHistoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Ajouter un achat à l'historique
  Future<bool> addPurchase({
    required String userId,
    required String orderId,
    required double totalAmount,
  }) async {
    try {
      final db = await _dbHelper.database;
      final historyId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('purchase_history', {
        'historyId': historyId,
        'userId': userId,
        'orderId': orderId,
        'totalAmount': totalAmount,
        'purchaseDate': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error adding purchase to history: $e');
      return false;
    }
  }

  /// Obtenir l'historique des achats
  Future<List<Map<String, dynamic>>> getPurchaseHistory(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT ph.*, o.status, o.deliveryAddress, o.paymentMethod, s.storename
        FROM purchase_history ph
        JOIN orders o ON ph.orderId = o.orderId
        JOIN stores s ON o.storeId = s.storeId
        WHERE ph.userId = ?
        ORDER BY ph.purchaseDate DESC
      ''', [userId]);
    } catch (e) {
      debugPrint('Error getting purchase history: $e');
      return [];
    }
  }

  /// Obtenir les statistiques d'achat
  Future<Map<String, dynamic>> getPurchaseStats(String userId, {int? month, int? year}) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final targetMonth = month ?? now.month;
      final targetYear = year ?? now.year;

      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as totalPurchases,
          SUM(totalAmount) as totalSpent,
          AVG(totalAmount) as averagePurchase
        FROM purchase_history
        WHERE userId = ? 
          AND strftime('%m', purchaseDate) = ?
          AND strftime('%Y', purchaseDate) = ?
      ''', [userId, targetMonth.toString().padLeft(2, '0'), targetYear.toString()]);

      return result.isNotEmpty ? result.first : {
        'totalPurchases': 0,
        'totalSpent': 0.0,
        'averagePurchase': 0.0,
      };
    } catch (e) {
      debugPrint('Error getting purchase stats: $e');
      return {
        'totalPurchases': 0,
        'totalSpent': 0.0,
        'averagePurchase': 0.0,
      };
    }
  }
}


