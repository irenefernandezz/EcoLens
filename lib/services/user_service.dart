import 'dart:async';
import 'package:helloworld/models/user.dart';
import 'package:helloworld/database/initDB.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  final _userController = StreamController<User?>.broadcast();

  Stream<User?> get userStream => _userController.stream;

  Future<User?> getCurrentUser() async {
    final db = await DatabaseHelper.instance.database;
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if(username == null) return null;

    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (users.isNotEmpty) {
      User currentUser = User.fromMap(users.first);
      return currentUser;
    }
    return null;
  }

  Future<User?> findUser(String email) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (users.isNotEmpty) {
      User currentUser = User.fromMap(users.first);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', currentUser.username);
      _userController.add(currentUser); // Notificar
      return currentUser;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
      _userController.add(null); // Notificar
      return null;
    }
  }

  Future<void> saveUser(User user) async {
    final db = await DatabaseHelper.instance.database;
    
    await db.insert(
      'users',
      {
        'username': user.username,
        'password': user.password,
        'email': user.email,
        'avatar': user.avatar,
      },
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', user.username);
    _userController.add(user); // Notificar
  }

  Future<void> updateUser(User user) async {
    final db = await DatabaseHelper.instance.database;
    
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', user.username);
    
    _userController.add(user);
  }

  Future<void> deleteUser(User user) async {
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [user.id],
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    _userController.add(null); // Notificar
  }

  void dispose() {
    _userController.close();
  }
}
