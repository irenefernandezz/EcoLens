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
}
