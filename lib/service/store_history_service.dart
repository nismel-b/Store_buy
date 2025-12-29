
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class StoreHistoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add history entry
  Future<void> addHistory({
    required String storeId,
    required String action,
    String? details,
    String? userId,
  }) async {
    try {
      final db = await _dbHelper.database;
      final historyId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('store_history', {
        'historyId': historyId,
        'storeId': storeId,
        'action': action,
        'details': details,
        'userId': userId,
        'createdAt': now,
      });
    } catch (e) {
      debugPrint('Error adding history: $e');
    }
  }

  // Get history by store with date range
  Future<List<Map<String, dynamic>>> getHistoryByStore(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await _dbHelper.database;
      String query = '''
        SELECT h.*, u.name as userName
        FROM store_history h
        LEFT JOIN users u ON h.userId = u.userId
        WHERE h.storeId = ?
      ''';
      List<dynamic> args = [storeId];

      if (startDate != null) {
        query += ' AND h.createdAt >= ?';
        args.add(DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate));
      }

      if (endDate != null) {
        query += ' AND h.createdAt <= ?';
        args.add(DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate));
      }

      query += ' ORDER BY h.createdAt DESC';

      return await db.rawQuery(query, args);
    } catch (e) {
      debugPrint('Error getting history: $e');
      return [];
    }
  }

  // Get monthly statistics
  Future<Map<String, dynamic>> getMonthlyStats(String storeId, int monthsBack) async {
    try {
      final db = await _dbHelper.database;
      final startDate = DateTime.now().subtract(Duration(days: 30 * monthsBack));
      final startDateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate);

      // Get orders count and total
      final ordersStats = await db.rawQuery('''
        SELECT COUNT(*) as count, SUM(totalAmount) as total
        FROM orders
        WHERE storeId = ? AND createdAt >= ?
      ''', [storeId, startDateStr]);

      // Get products added
      final productsStats = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM products
        WHERE storeId = ? AND createdAt >= ?
      ''', [storeId, startDateStr]);

      // Get history actions
      final historyStats = await db.rawQuery('''
        SELECT action, COUNT(*) as count
        FROM store_history
        WHERE storeId = ? AND createdAt >= ?
        GROUP BY action
      ''', [storeId, startDateStr]);

      return {
        'orders': {
          'count': ordersStats.first['count'] ?? 0,
          'total': ordersStats.first['total'] ?? 0.0,
        },
        'products': {
          'count': productsStats.first['count'] ?? 0,
        },
        'actions': historyStats.map((e) => {
          'action': e['action'],
          'count': e['count'],
        }).toList(),
      };
    } catch (e) {
      debugPrint('Error getting monthly stats: $e');
      return {};
    }
  }
}


