
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Service pour gérer les avis sur les magasins
class StoreReviewService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Ajouter un avis sur un magasin
  Future<bool> addStoreReview({
    required String userId,
    required String storeId,
    required int rating,
    String? comment,
  }) async {
    try {
      final db = await _dbHelper.database;
      final reviewId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('store_reviews', {
        'reviewId': reviewId,
        'userId': userId,
        'storeId': storeId,
        'rating': rating,
        'comment': comment,
        'createdAt': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error adding store review: $e');
      return false;
    }
  }

  /// Obtenir les avis d'un magasin
  Future<List<Map<String, dynamic>>> getStoreReviews(String storeId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT sr.*, u.name as userName, u.username
        FROM store_reviews sr
        JOIN users u ON sr.userId = u.userId
        WHERE sr.storeId = ?
        ORDER BY sr.createdAt DESC
      ''', [storeId]);
    } catch (e) {
      debugPrint('Error getting store reviews: $e');
      return [];
    }
  }

  /// Obtenir la note moyenne d'un magasin
  Future<double> getAverageRating(String storeId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT AVG(rating) as avgRating
        FROM store_reviews
        WHERE storeId = ?
      ''', [storeId]);
      return (result.first['avgRating'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('Error getting average rating: $e');
      return 0.0;
    }
  }
}


