import 'dart:convert';
import 'package:helloworld/screens/history_screen.dart';
import 'package:helloworld/services/history_service.dart';
import 'package:helloworld/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:helloworld/responses/product_response.dart';
import 'package:helloworld/database/initDB.dart';
import 'package:logger/logger.dart';

// Configuración de logger
var logger = Logger(
  printer: PrettyPrinter(),
);


class ProductService {
  ProductResponse? currentProduct;
  final historyService = HistoryService();

  Future<ProductResponse> fetchProduct(String? id) async {
    if (id == null) throw Exception("Id is null");

    final res = await http.get(Uri.parse('https://world.openfoodfacts.org/api/v0/product/$id.json'));

    if (res.statusCode == 200) {
      var data = json.decode(res.body);

      if (data['status'] == 1) {
        final productResponse = ProductResponse.fromJson(data);
        currentProduct = productResponse;
        
        // Guardar en la base de datos local incluyendo el score
        await _saveToDatabase(productResponse, id);

        return productResponse;
      } else {
        throw Exception("Product not found");
      }
    } else {
      throw Exception("Error fetching product: ${res.statusCode}");
    }
  }

  Future<void> _saveToDatabase(ProductResponse response, String barcode) async {
    final db = await DatabaseHelper.instance.database;
    final double? calculatedScore = currentProduct?.calculateTotalScore();

    final List<Map<String, dynamic>> existingProducts = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    int productId;

    if (existingProducts.isNotEmpty) {
      // SI YA EXISTE: obtener el ID y actualizar los datos por si han cambiado
      productId = existingProducts.first['id'];
      await db.update(
        'products',
        {
          'nombre': response.name_es.isNotEmpty ? response.name_es : response.name_en,
          'img_url': response.image_url,
          'score': calculatedScore,
        },
        where: 'id = ?',
        whereArgs: [productId],
      );
    } else {
      productId = await db.insert(
        'products',
        {
          'barcode': barcode,
          'nombre': response.name_es.isNotEmpty ? response.name_es : response.name_en,
          'img_url': response.image_url,
          'score': calculatedScore,
        },
      );
    }


    final currentUser = await UserService().getCurrentUser();

    if (currentUser != null && currentUser.id != null) {

      historyService.addRegister(currentUser.id!, productId);
    }

    logger.d("Producto procesado en BD con ID local: $productId");
  }

}
