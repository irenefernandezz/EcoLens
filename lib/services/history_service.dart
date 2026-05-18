import 'package:helloworld/models/product_user.dart';
import 'package:helloworld/models/product.dart';
import '../database/initDB.dart';

class HistoryService {

  Future<List<Product_user>> getAllByUser(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return maps.map((item) {
      return Product_user.fromMap(item);
    }).toList();
  }

  // Obtener todos los productos escaneados en la app (todos los usuarios)
  Future<List<Product>> getAllScannedProducts() async {
    final db = await DatabaseHelper.instance.database;
    // Corregido: Realizamos un JOIN con la tabla products para obtener los datos completos del producto
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.* FROM products p
      INNER JOIN history h ON p.id = h.product_id
    ''');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<List<Product>> getProductsByUser(int userId) async {
    final db = await DatabaseHelper.instance.database;
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.* FROM products p
      INNER JOIN history h ON p.id = h.product_id
      WHERE h.user_id = ?
      ORDER BY h.fecha_scan DESC
    ''', [userId]);

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<void> addRegister(int userid, int productid) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> existingHistory = await db.query(
      'history',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userid, productid],
    );


    if (existingHistory.isEmpty) {
      await db.insert(
        'history',
        {
          'user_id': userid,
          'product_id': productid,
          'fecha_scan': DateTime.now().toIso8601String(),
        },
      );
    }
  }
}
