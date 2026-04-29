import 'package:flutter/material.dart';
import 'package:helloworld/models/product.dart';
import 'package:helloworld/services/history_service.dart';
import 'package:helloworld/services/user_service.dart';
import 'package:helloworld/services/product_service.dart';
import 'detail_result.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final user = _userService.getCurrentUser();

    if (user == null || user.id == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to see your history.')),
      );
    }

    return Scaffold(

      appBar: AppBar(
        // Barra superior
        title: const Text(
          'Scan History',
          style: TextStyle(
            color: Color(0xFF6DA67A),
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
        centerTitle: true,
      ),

      // Lista de productos
      body: FutureBuilder<List<Product>>(
        future: _historyService.getProductsByUser(user.id!),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Center(child: Text('Error loading the data'));
          }

          final products = snapshot.data ?? [];

          //Si aún no se escanearon productos
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products scanned yet!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          //Widget en forma de lista para cada producto
          return ListView.separated(
            //Para que no ocupen todo el ancho de la pantalla
            padding: const EdgeInsets.all(16),

            itemCount: products.length,
            //Separación entre elementos
            separatorBuilder: (context, index) => const SizedBox(height: 20),

            itemBuilder: (context, index) {
              final product = products[index];

              //Hacer clickable
              return InkWell(
                onTap: () async {
                  try {
                    //Navegar a la pestaña de detalle de producto
                    final fullProduct = await _productService.fetchProduct(product.barcode);
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailResult(product: fullProduct),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error loading details: $e')),
                      );
                    }
                  }
                },
                child: Container(

                  //Estilo de cada elemento
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      // Imagen del producto
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                        child: Image.network(
                                product.imgUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                      ),
                      const SizedBox(width: 15),

                      //Para que el nombre ocupe todo el espacio sobrante
                      Expanded(
                        //Margen interno
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),

                      // Nota Total
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Text(
                              product.score.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(product.score),
                              ),
                            ),
                            const Text('/10', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  //Color de la nota
  Color _getScoreColor(double score) {
    if (score >= 7) return const Color(0xFF6DA67A);
    if (score >= 4) return const Color(0xFFFBC02D);
    return const Color(0xFFE57373);
  }
}
