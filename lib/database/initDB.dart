import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  //Singleton
  static final DatabaseHelper instance = DatabaseHelper._init();

  //Base de datos
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    //Ruta y nombre de la base de datos
    final path = join(await getDatabasesPath(), 'eco_app.db');

    return openDatabase(
      path,
      version: 3, //Cada vez que se cambia una columna se ha de incrementar la versión

      //Activar claves foráneas
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      //Tablas y atributos
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
          img_url TEXT,
          score REAL
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
    );
  }
}
