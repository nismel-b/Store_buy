
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:store_buy/model/login_model.dart';
import 'package:store_buy/utils/security_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Register a new user
  Future<User?> registerUser({
    required String name,
    required String username,
    required String email,
    required String phonenumber,
    required String password,
    required String location,
    required UserType userType,
  }) async {
    try {
      final db = await _dbHelper.database;
      final userId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('users', {
        'userId': userId,
        'name': name,
        'username': username,
        'email': email,
        'phonenumber': phonenumber,
        'password': SecurityHelper.hashPassword(password), // Hash password for security
        'location': location,
        'userType': userType.toString().split('.').last,
        'createdAt': now,
      });

      return User(
        userId,
        name,
        username,
        email,
        phonenumber,
        password,
        location,
        userType,
      );
    } catch (e) {
      debugPrint('Error registering user: $e');
      return null;
    }
  }

  // Login user
  Future<User?> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final db = await _dbHelper.database;
      // Get user by username first
      final userResult = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      
      if (userResult.isEmpty) return null;
      
      // Verify password hash
      final storedHash = userResult.first['password'] as String;
      if (!SecurityHelper.verifyPassword(password, storedHash)) {
        return null;
      }
      
      final result = userResult;

      if (result.isNotEmpty) {
        final userData = result.first;
        return User(
          userData['userId'] as String,
          userData['name'] as String,
          userData['username'] as String,
          userData['email'] as String? ?? '',
          userData['phonenumber'] as String? ?? '',
          userData['password'] as String,
          userData['location'] as String? ?? '',
          userData['userType'] == 'vendor' ? UserType.vendor : UserType.customer,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return null;
    }
  }

  // Check if username exists
  Future<bool> usernameExists(String username) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking username: $e');
      return false;
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (result.isNotEmpty) {
        final userData = result.first;
        return User(
          userData['userId'] as String,
          userData['name'] as String,
          userData['username'] as String,
          userData['email'] as String? ?? '',
          userData['phonenumber'] as String? ?? '',
          userData['password'] as String,
          userData['location'] as String? ?? '',
          userData['userType'] == 'vendor' ? UserType.vendor : UserType.customer,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }
}

