import 'package:flutter/material.dart';
import 'package:helloworld/screens/profile_screen.dart';
import 'package:helloworld/services/history_service.dart';
import 'package:helloworld/services/product_service.dart';
import 'package:helloworld/services/user_service.dart';
import 'package:helloworld/models/user.dart' as model;
import '../shared/logout_dialog.dart';

import 'detail_result.dart';
import 'package:logger/logger.dart';

// Configuración de logger
var logger = Logger(
  printer: PrettyPrinter(),
);

//StatefulWidget para evitar operaciones asíncronas con Future en el build
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});


  @override
  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {
  // Inicializar servicios
  final historyService = HistoryService();
  final userService = UserService();
  final productService = ProductService();
  late final currentUser;

  int _scannedCount = 0; // Variable para guardar el número de productos escaneados

  @override
  void initState() {
    super.initState();
    _loadCount(); //Cargar el número de productos escaneados
    _loadName();
  }

  Future<void> _loadName() async {
    final username = await userService.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = username;
      });
    }
  }

  Future<void> _loadCount() async {
    final count = await getScannedProducts();
    if (mounted) {
      setState(() {
        _scannedCount = count;
      });
    }
  }

  // Calcula el número de productos escaneados por el usuario
  Future<int> getScannedProducts() async {
    final id = currentUser?.id;
    if (id != null) {
      final list = await historyService.getProductsByUser(id);
      return list.length;
    } else {
      return -1;
    }
  }

  // Obtener el barcode del último producto escaneado para enlazarlo con el botón
  Future<String?> getLastScannedProduct() async {
    final id = currentUser.id;
    if (id != null) {
      final list = await historyService.getProductsByUser(id);
      if (list.isNotEmpty) {
        return list.first.barcode;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(

        //Stack en lugar de Column para tener una mayor flexibilidad a la hora de posicionar los elementos.
        //Column = elementos uno debajo de otro
        child: Stack(
          children: [

            // Botón arriba a la derecha del perfil del usuario
            Positioned(
              //Coordenadas exactas
              top: 10,
              right: 10,

              //Cambiar para usar el usuario actual directamente
              //Se usa StreamBuilder para reflear cambios en tiempo real sobre la foto de perfil, en lugar de llamar a userService.getCurrentUser()
              child: StreamBuilder<model.User?>(
                stream: userService.userStream,
                initialData: currentUser,
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  final avatarUrl = user?.avatar ?? 'lib/resources/profile.png';

                  //Popup del botón de perfil
                  return PopupMenuButton<String>(
                    //Coordenadas
                    offset: const Offset(-40, 70),
                    //Forma del Popup
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        showLogoutDialog(context);
                      } else if (value == 'profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      }
                      logger.d('Opción seleccionada: $value');
                    },
                    //Aspecto de las opciones del popup
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('My Profile'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_outlined, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                    //Imagen del usuairo con sombra
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        avatarUrl,
                        height: 100,
                        width: 100,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Contenido central: nombre app + logo + mensaje productos escaneados + botón último escaneo
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título
                  const Text(
                    'EcoLens',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6DA67A),
                      fontFamily: 'Georgia',
                    ),
                  ),

                  // Logo
                  const SizedBox(height: 20),
                  Image.asset(
                    'lib/resources/logo.png',
                    height: 250,
                  ),
                  const SizedBox(height: 20),

                  // Botón último escaneo
                  OutlinedButton(
                    onPressed: () async {
                      final barcode = await getLastScannedProduct();
                      if (barcode != null) {
                        final lastProduct = await productService.fetchProduct(barcode);
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailResult(product: lastProduct),
                            ),
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF86C28B), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'View last product',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),

                  const SizedBox(height: 30),

                  //Texto indicando los productos escaneados
                  Text(
                    _scannedCount <= 0
                    ? 'Start scanning products!'
                    : 'You have scanned $_scannedCount products',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
