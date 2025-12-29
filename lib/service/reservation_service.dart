
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ReservationService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create reservation
  Future<String?> createReservation({
    required String orderId,
    required String storeId,
    required String userId,
    required String type, // 'delivery' or 'pickup'
    String? pickupDate,
  }) async {
    try {
      final db = await _dbHelper.database;
      final reservationId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('reservations', {
        'reservationId': reservationId,
        'orderId': orderId,
        'storeId': storeId,
        'userId': userId,
        'type': type,
        'pickupDate': pickupDate,
        'status': 'pending',
        'createdAt': now,
      });

      return reservationId;
    } catch (e) {
      debugPrint('Error creating reservation: $e');
      return null;
    }
  }

  // Get reservations by store
  Future<List<Map<String, dynamic>>> getReservationsByStore(String storeId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT r.*, o.totalAmount, o.status as orderStatus, u.name as userName
        FROM reservations r
        JOIN orders o ON r.orderId = o.orderId
        JOIN users u ON r.userId = u.userId
        WHERE r.storeId = ?
        ORDER BY r.createdAt DESC
      ''', [storeId]);
    } catch (e) {
      debugPrint('Error getting reservations: $e');
      return [];
    }
  }

  // Update reservation status
  Future<bool> updateReservationStatus(String reservationId, String status) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'reservations',
        {'status': status},
        where: 'reservationId = ?',
        whereArgs: [reservationId],
      );
      return true;
    } catch (e) {
      debugPrint('Error updating reservation: $e');
      return false;
    }
  }
}


