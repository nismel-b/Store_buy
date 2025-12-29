
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Service pour gérer les photos du magasin physique
class StorePhotoService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Ajouter une photo au magasin
  Future<bool> addStorePhoto({
    required String storeId,
    required String photoUrl,
    String? description,
  }) async {
    try {
      final db = await _dbHelper.database;
      final photoId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('store_photos', {
        'photoId': photoId,
        'storeId': storeId,
        'photoUrl': photoUrl,
        'description': description,
        'createdAt': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error adding store photo: $e');
      return false;
    }
  }

  /// Obtenir toutes les photos d'un magasin
  Future<List<Map<String, dynamic>>> getStorePhotos(String storeId) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        'store_photos',
        where: 'storeId = ?',
        whereArgs: [storeId],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      debugPrint('Error getting store photos: $e');
      return [];
    }
  }

  /// Supprimer une photo
  Future<bool> deletePhoto(String photoId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('store_photos', where: 'photoId = ?', whereArgs: [photoId]);
      return true;
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      return false;
    }
  }
}


