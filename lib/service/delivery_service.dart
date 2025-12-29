
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class DeliveryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create delivery
  Future<String?> createDelivery({
    required String orderId,
    required String storeId,
    required String deliveryAddress,
    String? estimatedDate,
  }) async {
    try {
      final db = await _dbHelper.database;
      final deliveryId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('deliveries', {
        'deliveryId': deliveryId,
        'orderId': orderId,
        'storeId': storeId,
        'deliveryAddress': deliveryAddress,
        'status': 'pending',
        'estimatedDate': estimatedDate,
        'createdAt': now,
      });

      return deliveryId;
    } catch (e) {
      debugPrint('Error creating delivery: $e');
      return null;
    }
  }

  // Get deliveries by store
  Future<List<Map<String, dynamic>>> getDeliveriesByStore(String storeId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT d.*, o.totalAmount, o.status as orderStatus, u.name as userName, u.phonenumber
        FROM deliveries d
        JOIN orders o ON d.orderId = o.orderId
        JOIN users u ON o.userId = u.userId
        WHERE d.storeId = ?
        ORDER BY d.createdAt DESC
      ''', [storeId]);
    } catch (e) {
      debugPrint('Error getting deliveries: $e');
      return [];
    }
  }

  // Update delivery status
  Future<bool> updateDeliveryStatus(String deliveryId, String status, {String? actualDate}) async {
    try {
      final db = await _dbHelper.database;
      final updates = {'status': status};
      if (actualDate != null) {
        updates['actualDate'] = actualDate;
      }
      await db.update(
        'deliveries',
        updates,
        where: 'deliveryId = ?',
        whereArgs: [deliveryId],
      );
      return true;
    } catch (e) {
      debugPrint('Error updating delivery: $e');
      return false;
    }
  }
}


