import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'eco_app.db');

    return openDatabase(
      path,
      version: 2, // Incrementamos la versión a 2

      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          password TEXT NOT NULL,
          email TEXT NOT NULL,
          avatar TEXT
        );
      ''');

        await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          barcode TEXT UNIQUE,
          nombre TEXT,
          img_url TEXT
        );
      ''');

        await db.execute('''
        CREATE TABLE history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          product_id INTEGER,
          fecha_scan TEXT,
          FOREIGN KEY(user_id) REFERENCES users(id),
          FOREIGN KEY(product_id) REFERENCES products(id)
        );
      ''');
      },
      
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Si el usuario ya tenía la v1, añadimos la columna avatar
          await db.execute('ALTER TABLE users ADD COLUMN avatar TEXT');
        }
      },
    );
  }
}
