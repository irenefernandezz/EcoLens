import 'package:helloworld/models/user.dart';
import 'package:helloworld/database/initDB.dart';

class UserService {
  // Instancia única (Singleton)
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  User? _currentUser;

  User? getCurrentUser() {
    return _currentUser;
  }

  Future<User?> findUser(String email) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (users.isNotEmpty) {
      _currentUser = User.fromMap(users.first);
      return _currentUser;
    } else {
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
    
    _currentUser = user;
  }

  Future<void> updateUser(User user) async {
    final db = await DatabaseHelper.instance.database;
    
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    
    _currentUser = user;
  }

  Future<void> deleteUser(User user) async {
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [user.id],
    );
    _currentUser = null;
  }
}
