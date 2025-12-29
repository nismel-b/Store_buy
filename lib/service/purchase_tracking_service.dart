import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Service pour tracker les achats et gérer la liste d'attente
class PurchaseTrackingService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Ajouter un produit à la liste de suivi
  Future<bool> addToTracking({
    required String userId,
    required String productId,
    int priority = 0,
  }) async {
    try {
      final db = await _dbHelper.database;
      final trackingId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('purchase_tracking', {
        'trackingId': trackingId,
        'userId': userId,
        'productId': productId,
        'priority': priority,
        'status': 'pending',
        'createdAt': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      return true;
    } catch (e) {
      debugPrint('Error adding to tracking: $e');
      return false;
    }
  }

  /// Obtenir la liste de suivi triée par priorité
  Future<List<Map<String, dynamic>>> getTrackingList(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT pt.*, p.productName, p.price, p.photo, p.quantity
        FROM purchase_tracking pt
        JOIN products p ON pt.productId = p.productId
        WHERE pt.userId = ? AND pt.status = 'pending'
        ORDER BY pt.priority DESC, pt.createdAt ASC
      ''', [userId]);
    } catch (e) {
      debugPrint('Error getting tracking list: $e');
      return [];
    }
  }

  /// Mettre à jour la priorité
  Future<bool> updatePriority(String trackingId, int priority) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'purchase_tracking',
        {'priority': priority},
        where: 'trackingId = ?',
        whereArgs: [trackingId],
      );
      return true;
    } catch (e) {
      debugPrint('Error updating priority: $e');
      return false;
    }
  }

  /// Marquer comme acheté
  Future<bool> markAsPurchased(String trackingId) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'purchase_tracking',
        {'status': 'purchased'},
        where: 'trackingId = ?',
        whereArgs: [trackingId],
      );
      return true;
    } catch (e) {
      debugPrint('Error marking as purchased: $e');
      return false;
    }
  }

  /// Retirer de la liste
  Future<bool> removeFromTracking(String trackingId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('purchase_tracking', where: 'trackingId = ?', whereArgs: [trackingId]);
      return true;
    } catch (e) {
      debugPrint('Error removing from tracking: $e');
      return false;
    }
  }
}


