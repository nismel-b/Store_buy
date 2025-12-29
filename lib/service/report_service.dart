
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Service pour gérer les signalements de vendeurs/clients
class ReportService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Signaler un utilisateur
  Future<bool> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      final db = await _dbHelper.database;
      final reportId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('reports', {
        'reportId': reportId,
        'reporterId': reporterId,
        'reportedUserId': reportedUserId,
        'storeId': null,
        'reason': reason,
        'description': description,
        'status': 'pending',
        'createdAt': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error reporting user: $e');
      return false;
    }
  }

  /// Signaler un magasin
  Future<bool> reportStore({
    required String reporterId,
    required String storeId,
    required String reason,
    String? description,
  }) async {
    try {
      final db = await _dbHelper.database;
      final reportId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('reports', {
        'reportId': reportId,
        'reporterId': reporterId,
        'reportedUserId': null,
        'storeId': storeId,
        'reason': reason,
        'description': description,
        'status': 'pending',
        'createdAt': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error reporting user: $e');
      return false;
    }
  }
}

