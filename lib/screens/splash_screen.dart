import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/screens/profile_screen.dart';
import 'package:helloworld/services/history_service.dart';
import 'package:helloworld/services/product_service.dart';
import 'package:helloworld/services/user_service.dart';
import 'package:helloworld/models/user.dart' as model;

import 'detail_result.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final historyService = HistoryService();
    final userService = UserService();
    final productService = ProductService();

    Future<int> getScannedProducts() async {
      final id = userService.getCurrentUser()?.id;
      if(id != null){
        final list = await historyService.getProductsByUser(id);
      return list.length;
      }
      else {
        return -1;
      }
    }

    Future<String?> getLastScannedProduct() async {
      final id = userService.getCurrentUser()?.id;
      if(id != null){
        final list = await historyService.getProductsByUser(id);
        return list.first.barcode;
      }
      else {
        return null;
      }
    }

    return Scaffold(
      //Para evitar que elementos de la UI interfieran con el tamaño de la pantalla
      body: SafeArea(
        child: Stack(
          children: [
            // Botón arriba a la derecha del perfil del usuario
            Positioned(
              top: 10,
              right: 10,
              child: StreamBuilder<model.User?>(
                stream: userService.userStream,
                initialData: userService.getCurrentUser(),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  final avatarUrl = user?.avatar ?? 'lib/resources/profile.png';
                  
                  return PopupMenuButton<String>(
                    offset: const Offset(-40, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (value) {
                      if (value == 'logout') {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      }
                      else if (value == 'profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      }
                      // Lógica para cada opción
                      print('Opción seleccionada: $value');
                    },
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
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3), // Menos opacidad para que sea más sutil
                            spreadRadius: 0,
                            blurRadius: 10, // Menos difuminado para que no se expanda tanto
                            offset: const Offset(0, 5), // Menos desplazamiento
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
                }
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

                  // Botón último escaneo
                  const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () async {
                        final scannedProducts = await getScannedProducts();
                          if(scannedProducts > 0){
                            var barcode =  await getLastScannedProduct();
                            final fullProduct = await productService.fetchProduct(barcode);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailResult(product: fullProduct),
                              ),
                            );

                          }

                        },
                      //estilo del botón
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
                  FutureBuilder<int>(
                    future: getScannedProducts(), // La función que obtiene el número
                    builder: (context, snapshot) {
                      // Mientras carga los datos
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      // Si hubo un error
                      if (snapshot.hasError) {
                        return const Text('Error loading data');
                      }

                      // Cuando ya tenemos el resultado
                      final count = snapshot.data ?? 0;

                      return Text(
                        count <= 0
                            ? 'Start scanning products!'
                            : 'You have scanned $count products',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      );
                    },
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
