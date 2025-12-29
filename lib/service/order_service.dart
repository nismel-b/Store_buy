
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:store_buy/model/commande.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class OrderService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create a new order
  Future<String?> createOrder({
    required String userId,
    required String storeId,
    required double totalAmount,
    required String deliveryAddress,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final db = await _dbHelper.database;
      final orderId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.transaction((txn) async {
        // Create order
        await txn.insert('orders', {
          'orderId': orderId,
          'userId': userId,
          'storeId': storeId,
          'totalAmount': totalAmount,
          'status': EtatCommande.encours.toString().split('.').last,
          'deliveryAddress': deliveryAddress,
          'paymentMethod': paymentMethod,
          'createdAt': now,
        });

        // Add order items
        for (var item in items) {
          final orderItemId = const Uuid().v4();
          await txn.insert('order_items', {
            'orderItemId': orderItemId,
            'orderId': orderId,
            'productId': item['productId'],
            'quantity': item['quantity'],
            'price': item['price'],
          });

          // Update product quantity
          await txn.rawUpdate(
            'UPDATE products SET quantity = quantity - ? WHERE productId = ?',
            [item['quantity'], item['productId']],
          );
        }
      });

      return orderId;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }

  // Get orders by user
  Future<List<Map<String, dynamic>>> getOrdersByUser(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT o.*, s.storename, s.photo as storePhoto
        FROM orders o
        JOIN stores s ON o.storeId = s.storeId
        WHERE o.userId = ?
        ORDER BY o.createdAt DESC
      ''', [userId]);
    } catch (e) {
      debugPrint('Error getting orders by user: $e');
      return [];
    }
  }

  // Get orders by store
  Future<List<Map<String, dynamic>>> getOrdersByStore(String storeId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT o.*, u.name as userName, u.phonenumber
        FROM orders o
        JOIN users u ON o.userId = u.userId
        WHERE o.storeId = ?
        ORDER BY o.createdAt DESC
      ''', [storeId]);
    } catch (e) {
      debugPrint('Error getting orders by store: $e');
      return [];
    }
  }

  // Get order details with items
  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    try {
      final db = await _dbHelper.database;
      final order = await db.query(
        'orders',
        where: 'orderId = ?',
        whereArgs: [orderId],
      );

      if (order.isEmpty) return null;

      final items = await db.rawQuery('''
        SELECT oi.*, p.productName, p.photo
        FROM order_items oi
        JOIN products p ON oi.productId = p.productId
        WHERE oi.orderId = ?
      ''', [orderId]);

      return {
        'order': order.first,
        'items': items,
      };
    } catch (e) {
      debugPrint('Error getting order details: $e');
      return null;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, EtatCommande status) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'orders',
        {'status': status.toString().split('.').last},
        where: 'orderId = ?',
        whereArgs: [orderId],
      );
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  // Get order statistics for store
  Future<Map<String, dynamic>> getOrderStatistics(String storeId) async {
    try {
      final db = await _dbHelper.database;
      
      final totalOrders = await db.rawQuery(
        'SELECT COUNT(*) as count FROM orders WHERE storeId = ?',
        [storeId],
      );
      
      final totalSales = await db.rawQuery(
        'SELECT SUM(totalAmount) as total FROM orders WHERE storeId = ? AND status = ?',
        [storeId, 'termine'],
      );
      
      final pendingOrders = await db.rawQuery(
        'SELECT COUNT(*) as count FROM orders WHERE storeId = ? AND status = ?',
        [storeId, 'encours'],
      );

      final totalSalesValue = totalSales.isNotEmpty 
          ? (totalSales.first['total'] as num?) 
          : null;
      final totalOrdersValue = totalOrders.isNotEmpty 
          ? (totalOrders.first['count'] as int?) 
          : null;
      final pendingOrdersValue = pendingOrders.isNotEmpty 
          ? (pendingOrders.first['count'] as int?) 
          : null;
      return {
        'totalOrders': totalOrdersValue ?? 0,
        'totalSales': totalSalesValue?.toDouble() ?? 0.0,
        'pendingOrders': pendingOrdersValue ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting order statistics: $e');
      return {
        'totalOrders': 0,
        'totalSales': 0.0,
        'pendingOrders': 0,
      };
    }
  }
}

