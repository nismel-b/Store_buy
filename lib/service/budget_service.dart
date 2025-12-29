import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Service pour gérer les limites de budget mensuel
class BudgetService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Définir une limite de budget mensuel
  Future<bool> setMonthlyBudget({
    required String userId,
    required double monthlyLimit,
  }) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final budgetId = const Uuid().v4();

      await db.insert('budget_limits', {
        'budgetId': budgetId,
        'userId': userId,
        'monthlyLimit': monthlyLimit,
        'currentSpent': 0.0,
        'month': now.month,
        'year': now.year,
        'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      return true;
    } catch (e) {
      debugPrint('Error setting budget: $e');
      return false;
    }
  }

  /// Obtenir le budget actuel
  Future<Map<String, dynamic>?> getCurrentBudget(String userId) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final result = await db.query(
        'budget_limits',
        where: 'userId = ? AND month = ? AND year = ?',
        whereArgs: [userId, now.month, now.year],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('Error getting budget: $e');
      return null;
    }
  }

  /// Ajouter une dépense au budget
  Future<bool> addExpense(String userId, double amount) async {
    try {
      final db = await _dbHelper.database;
      final budget = await getCurrentBudget(userId);
      if (budget != null) {
        final newSpent = (budget['currentSpent'] as num).toDouble() + amount;
        await db.update(
          'budget_limits',
          {'currentSpent': newSpent},
          where: 'budgetId = ?',
          whereArgs: [budget['budgetId']],
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error adding expense: $e');
      return false;
    }
  }

  /// Vérifier si le budget est dépassé
  Future<bool> isBudgetExceeded(String userId) async {
    try {
      final budget = await getCurrentBudget(userId);
      if (budget == null) return false;
      final limit = (budget['monthlyLimit'] as num).toDouble();
      final spent = (budget['currentSpent'] as num).toDouble();
      return spent >= limit;
    } catch (e) {
      debugPrint('Error checking budget: $e');
      return false;
    }
  }
}


