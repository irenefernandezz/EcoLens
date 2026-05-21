import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:helloworld/services/product_service.dart';
import 'package:helloworld/screens/detail_result.dart';
import 'package:toastification/toastification.dart';
import 'package:logger/logger.dart';
import 'package:vibration/vibration.dart';

// Configuración de logger
var logger = Logger(
  printer: PrettyPrinter(),
);


class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {

  bool manually = false;
  //Para que no se escanee un mismo producto en varios frames
  bool _isProcessing = false;
  final TextEditingController _controller = TextEditingController();
  final ProductService productService = ProductService();

  @override
  void initState() {
    super.initState();
    _isProcessing = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onCodeDetected(String code) async {
    try {
      final product = await productService.fetchProduct(code);

      if (!mounted) return;
      
      // Esperamos a que el usuario regrese de la pantalla de detalles
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailResult(product: product)),
      );

      // Al volver, permitimos escanear de nuevo
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _controller.clear();
        });
      }

    } catch (e) {
      if (!mounted) return;
      _showProductNotFoundToast(code);

      // Si hubo un error, permitir escanear de nuevo
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    }
  }

  void _showProductNotFoundToast(String barcode) {
    logger.d("Showing product not found toast for $barcode");
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 4),
      title: Text('Product not found for barcode: $barcode', style: const TextStyle(fontWeight: FontWeight.bold)),
      alignment: Alignment.bottomCenter,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 600),
      icon: const Icon(Icons.not_interested),
      showIcon: true,
      primaryColor: Colors.red ,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      // Margen inferior aumentado para que el toast suba sobre el menú
      margin: const EdgeInsets.only(bottom: 110, left: 12, right: 12),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior
      appBar: AppBar(
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
          //Logo y descripción con posición absoluta
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
                //Centrar elementos
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  //El recuadro de la cámara
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
                      //La cámara
                      child: MobileScanner(
                        fit: BoxFit.cover,
                        onDetect: (capture) {
                          if(_isProcessing) return;
                          //Detectar códigos de barras
                          //vibración
                          setState(() {
                            _isProcessing = true;
                          });
                          Vibration.vibrate(duration: 500);
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

                        //Borde exterior verde redondeado
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Color(0xFF86C28B), width: 2),
                        ),

                        //Para que el borde se mantenga cuando se selecciona
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Color(0xFF86C28B), width: 2),
                        ),

                        //Icono de flecha
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_circle_right_rounded,
                                size: 35, color: Color(0xFF86C28B)),
                            onPressed: () {
                              if (_controller.text.isNotEmpty && !_isProcessing) {
                                setState(() {
                                  _isProcessing = true;
                                });
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
