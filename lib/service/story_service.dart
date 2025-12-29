import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class StoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add story
  Future<bool> addStory({
    required String storeId,
    required String imageUrl,
    required String type, // 'announcement' or 'promotion'
    String? title,
    String? description,
    double? promotionPrice,
    String? productId,
    int hoursToExpire = 24,
  }) async {
    try {
      final db = await _dbHelper.database;
      final storyId = const Uuid().v4();
      final now = DateTime.now();
      final expiresAt = now.add(Duration(hours: hoursToExpire));

      await db.insert('stories', {
        'storyId': storyId,
        'storeId': storeId,
        'imageUrl': imageUrl,
        'type': type,
        'title': title,
        'description': description,
        'promotionPrice': promotionPrice,
        'productId': productId,
        'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
        'expiresAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(expiresAt),
      });

      return true;
    } catch (e) {
      debugPrint('Error adding story: $e');
      return false;
    }
  }

  // Get active stories by store
  Future<List<Map<String, dynamic>>> getActiveStoriesByStore(String storeId) async {
    try {
      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      return await db.rawQuery('''
        SELECT * FROM stories
        WHERE storeId = ? AND expiresAt > ?
        ORDER BY createdAt DESC
      ''', [storeId, now]);
    } catch (e) {
      debugPrint('Error getting stories: $e');
      return [];
    }
  }

  // Get all stories by store
  Future<List<Map<String, dynamic>>> getStoriesByStore(String storeId) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        'stories',
        where: 'storeId = ?',
        whereArgs: [storeId],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      debugPrint('Error getting stories: $e');
      return [];
    }
  }

  // Delete story
  Future<bool> deleteStory(String storyId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('stories', where: 'storyId = ?', whereArgs: [storyId]);
      return true;
    } catch (e) {
      debugPrint('Error deleting story: $e');
      return false;
    }
  }
}


