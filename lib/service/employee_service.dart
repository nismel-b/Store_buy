
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class EmployeeService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add employee using code
  Future<bool> addEmployeeByCode({
    required String storeId,
    required String userId,
    required String code,
    String role = 'employee',
  }) async {
    try {
      final db = await _dbHelper.database;
      
      // Verify code
      final store = await db.query(
        'stores',
        where: 'storeId = ? AND code = ?',
        whereArgs: [storeId, code],
      );

      if (store.isEmpty) {
        return false; // Invalid code
      }

      // Check if already employee
      final existing = await db.query(
        'employees',
        where: 'storeId = ? AND userId = ?',
        whereArgs: [storeId, userId],
      );

      if (existing.isNotEmpty) {
        return false; // Already an employee
      }

      // Add employee
      final employeeId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('employees', {
        'employeeId': employeeId,
        'storeId': storeId,
        'userId': userId,
        'role': role,
        'code': code,
        'createdAt': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error adding employee: $e');
      return false;
    }
  }

  // Get employees by store
  Future<List<Map<String, dynamic>>> getEmployeesByStore(String storeId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT e.*, u.name, u.username, u.email, u.phonenumber
        FROM employees e
        JOIN users u ON e.userId = u.userId
        WHERE e.storeId = ?
        ORDER BY e.createdAt DESC
      ''', [storeId]);
    } catch (e) {
      debugPrint('Error getting employees: $e');
      return [];
    }
  }

  // Remove employee
  Future<bool> removeEmployee(String employeeId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('employees', where: 'employeeId = ?', whereArgs: [employeeId]);
      return true;
    } catch (e) {
      debugPrint('Error removing employee: $e');
      return false;
    }
  }

  // Check if user is employee of store
  Future<bool> isEmployee(String userId, String storeId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'employees',
        where: 'userId = ? AND storeId = ?',
        whereArgs: [userId, storeId],
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking employee: $e');
      return false;
    }
  }

  // Check if user is owner
  Future<bool> isOwner(String userId, String storeId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'stores',
        where: 'storeId = ? AND userId = ?',
        whereArgs: [storeId, userId],
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking owner: $e');
      return false;
    }
  }
}


