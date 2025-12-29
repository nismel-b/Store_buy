
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  // Create notification in database
  Future<bool> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    String? storeId,
  }) async {
    try {
      final db = await _dbHelper.database;
      final notificationId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('notifications', {
        'notificationId': notificationId,
        'userId': userId,
        'storeId': storeId,
        'type': type,
        'title': title,
        'body': body,
        'isRead': 0,
        'createdAt': now,
      });

      // Show local notification
      await _showLocalNotification(title, body, payload: notificationId);

      return true;
    } catch (e) {
      debugPrint('Error creating notification: $e');
      return false;
    }
  }

  Future<void> _showLocalNotification(String title, String body, {String? payload}) async {
    const androidDetails = AndroidNotificationDetails(
      'store_buy_channel',
      'Store Buy Notifications',
      channelDescription: 'Notifications for Store Buy app',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Get notifications by user
  Future<List<Map<String, dynamic>>> getNotificationsByUser(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        'notifications',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return [];
    }
  }

  // Mark as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'notifications',
        {'isRead': 1},
        where: 'notificationId = ?',
        whereArgs: [notificationId],
      );
      return true;
    } catch (e) {
      debugPrint('Error marking as read: $e');
      return false;
    }
  }

  // Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM notifications
        WHERE userId = ? AND isRead = 0
      ''', [userId]);
      return result.isNotEmpty 
          ? (result.first['count'] as int?) ?? 0
          : 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }
}

