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
        title: const Text(
          'Scan History',
          style: TextStyle(
            color: Color(0xFF6DA67A),
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Product>>(
        future: _historyService.getProductsByUser(user.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF86C28B)));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products scanned yet!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return InkWell(
                onTap: () async {


                  try {
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
                        child: product.imgUrl.isNotEmpty
                            ? Image.network(
                                product.imgUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
                              ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
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

  Color _getScoreColor(double score) {
    if (score >= 7) return const Color(0xFF6DA67A);
    if (score >= 4) return const Color(0xFFFBC02D);
    return const Color(0xFFE57373);
  }
}
