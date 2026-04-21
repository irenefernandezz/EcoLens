import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:helloworld/services/product_service.dart';
import 'package:helloworld/responses/product_response.dart';
import 'package:helloworld/screens/detail_result.dart';

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  bool manually = false;
  final TextEditingController _controller = TextEditingController();
  final ProductService productService = ProductService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Función de escaneo
  Future<void> _onCodeDetected(String code) async {
    try {
      final rawData = await productService.fetchProduct(code);
      final product = ProductResponse.fromJson(rawData);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailResult(product: product)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product not found. Please, try again')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'EcoLens Scanner',
          style: TextStyle(
            color: Color(0xFF6DA67A),
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
      ),
      body: Stack(
        children: [
          // Logo decorativo arriba
          Positioned(
            top: -5,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset(
                  'lib/resources/logo.png',
                  height: 100,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Check your product\'s eco-impact',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          if (!manually) ...[
            // La cámara limitada al recuadro central
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20), // Espacio para el logo superior
                  ClipRRect(
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF86C28B),
                          width: 7,
                        ),
                      ),
                      child: MobileScanner(
                        fit: BoxFit.cover,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                            _onCodeDetected(barcodes.first.rawValue!);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Center the barcode in the box',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            //Input text para introducir código de barras manualmente
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const SizedBox(height: 60),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: .center,
                      decoration: InputDecoration(
                        hintText: 'ej: 0 000000 000000',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Color(0xFF86C28B)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Color(0xFF86C28B), width: 2),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_circle_right_rounded,
                                size: 35, color: Color(0xFF86C28B)),
                            onPressed: () {
                              if (_controller.text.isNotEmpty) {
                                _onCodeDetected(_controller.text);
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                    const Text(
                      'Enter the barcode manually',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Botón inferior para alternar
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    manually = !manually;
                  });
                },
                icon: Icon(
                  manually ? Icons.qr_code_scanner : Icons.edit_note,
                  color: const Color(0xFF6DA67A),
                ),
                label: Text(
                  manually ? 'Switch to Scanner' : 'Switch to manual input',
                  style: const TextStyle(
                    color: Color(0xFF6DA67A),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
