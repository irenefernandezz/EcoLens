import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for products scanned
    const int scannedProducts = 0;

    return Scaffold(
      //Para evitar que elementos de la UI interfieran con el tamaño de la pantalla
      body: SafeArea(
        child: Stack(
          children: [
            // Botón arriba a la derecha del perfil del usuario
            Positioned(
              top: 10,
              right: 10,
              child: PopupMenuButton<String>(

                offset: const Offset(-40, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (value) {
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
                    'lib/resources/profile.png',
                    height: 100,
                    width: 100,
                  ),
                ),
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

                  // Mensaje productos escaneados
                  const SizedBox(height: 30),
                  Text(
                    scannedProducts == 0
                        ? 'Start scanning products!'
                        : 'You have scanned $scannedProducts products',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),

                  // Botón último escaneo
                  const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () {
                        if (scannedProducts > 0){// TODO: Navigate to last scanned product
                           }
                        else{}
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
