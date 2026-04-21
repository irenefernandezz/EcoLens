import 'dart:convert';

import 'package:http/http.dart' as http;

class ProductService {

  Future<dynamic> fetchProduct(String? id) async {

    if(id == null) throw Exception("Id is null");

    final res = await http.get(Uri.parse('https://world.openfoodfacts.org/api/v0/product/$id' '.json'));

    if (res.statusCode == 200) {
     return json.decode(res.body);

    } else {
      print("Error: ${res.statusCode}");
      throw Exception("Error: ${res.statusCode}");
    }

  }

}