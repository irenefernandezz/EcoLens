import 'package:helloworld/models/product_user.dart';

import '../database/initDB.dart';

class HistoryService {

  Future<List<Product_user>> getAllByUser(String userId) async {

    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('history',
    where: 'user_id = ?',
    whereArgs: [userId],
    );

    return maps.map((item) {
      return Product_user.fromJson({
        'id': item['id'],
        'user_id': item['user_id'],
        'product_id': item['product_id'],
        'timestamp': item['fecha_scan'],
      });
    }).toList();
  }

  }