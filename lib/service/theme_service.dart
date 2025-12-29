
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ThemeService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Save or update theme
  Future<bool> saveTheme({
    required String storeId,
    String? primaryColor,
    String? secondaryColor,
    String? fontFamily,
    String? logo,
    String? banner,
  }) async {
    try {
      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // Check if theme exists
      final existing = await db.query(
        'store_themes',
        where: 'storeId = ?',
        whereArgs: [storeId],
      );

      if (existing.isNotEmpty) {
        // Update
        await db.update(
          'store_themes',
          {
            'primaryColor': primaryColor,
            'secondaryColor': secondaryColor,
            'fontFamily': fontFamily,
            'logo': logo,
            'banner': banner,
            'updatedAt': now,
          },
          where: 'storeId = ?',
          whereArgs: [storeId],
        );
      } else {
        // Create
        final themeId = const Uuid().v4();
        await db.insert('store_themes', {
          'themeId': themeId,
          'storeId': storeId,
          'primaryColor': primaryColor,
          'secondaryColor': secondaryColor,
          'fontFamily': fontFamily,
          'logo': logo,
          'banner': banner,
          'updatedAt': now,
        });
      }

      return true;
    } catch (e) {
      debugPrint('Error saving theme: $e');
      return false;
    }
  }

  // Get theme by store
  Future<Map<String, dynamic>?> getThemeByStore(String storeId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'store_themes',
        where: 'storeId = ?',
        whereArgs: [storeId],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('Error getting theme: $e');
      return null;
    }
  }
}


