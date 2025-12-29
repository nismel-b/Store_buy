
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Service pour gérer les sondages des vendeurs
class SurveyService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Créer un sondage
  Future<bool> createSurvey({
    required String storeId,
    required String question,
    required String type, // 'yes_no', 'multiple_choice', 'text'
    List<String>? options,
    DateTime? expiresAt,
  }) async {
    try {
      final db = await _dbHelper.database;
      final surveyId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('surveys', {
        'surveyId': surveyId,
        'storeId': storeId,
        'question': question,
        'type': type,
        'options': options?.join('|'),
        'createdAt': now,
        'expiresAt': expiresAt?.toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error creating survey: $e');
      return false;
    }
  }

  /// Obtenir les sondages actifs d'un magasin
  Future<List<Map<String, dynamic>>> getActiveSurveys(String storeId) async {
    try {
      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      
      return await db.rawQuery('''
        SELECT * FROM surveys
        WHERE storeId = ? 
          AND (expiresAt IS NULL OR expiresAt > ?)
        ORDER BY createdAt DESC
      ''', [storeId, now]);
    } catch (e) {
      debugPrint('Error getting active surveys: $e');
      return [];
    }
  }

  /// Obtenir les sondages pour les clients (magasins où ils ont acheté)
  Future<List<Map<String, dynamic>>> getSurveysForCustomer(String userId) async {
    try {
      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      
      // Get surveys from stores where user has made purchases
      return await db.rawQuery('''
        SELECT DISTINCT s.*, st.storename
        FROM surveys s
        JOIN stores st ON s.storeId = st.storeId
        JOIN orders o ON o.storeId = s.storeId
        WHERE o.userId = ?
          AND (s.expiresAt IS NULL OR s.expiresAt > ?)
          AND s.surveyId NOT IN (
            SELECT surveyId FROM survey_responses WHERE userId = ?
          )
        ORDER BY s.createdAt DESC
      ''', [userId, now, userId]);
    } catch (e) {
      debugPrint('Error getting surveys for customer: $e');
      return [];
    }
  }

  /// Répondre à un sondage
  Future<bool> respondToSurvey({
    required String surveyId,
    required String userId,
    required String answer,
  }) async {
    try {
      final db = await _dbHelper.database;
      final responseId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('survey_responses', {
        'responseId': responseId,
        'surveyId': surveyId,
        'userId': userId,
        'answer': answer,
        'createdAt': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error responding to survey: $e');
      return false;
    }
  }

  /// Obtenir les réponses d'un sondage
  Future<List<Map<String, dynamic>>> getSurveyResponses(String surveyId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT sr.*, u.name as userName, u.username
        FROM survey_responses sr
        JOIN users u ON sr.userId = u.userId
        WHERE sr.surveyId = ?
        ORDER BY sr.createdAt DESC
      ''', [surveyId]);
    } catch (e) {
      debugPrint('Error getting survey responses: $e');
      return [];
    }
  }

  /// Supprimer un sondage
  Future<bool> deleteSurvey(String surveyId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('surveys', where: 'surveyId = ?', whereArgs: [surveyId]);
      return true;
    } catch (e) {
      debugPrint('Error deleting survey: $e');
      return false;
    }
  }
}


