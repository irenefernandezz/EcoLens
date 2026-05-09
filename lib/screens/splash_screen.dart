import 'package:flutter/material.dart';
import 'package:helloworld/screens/profile_screen.dart';
import 'package:helloworld/services/history_service.dart';
import 'package:helloworld/services/product_service.dart';
import 'package:helloworld/services/user_service.dart';
import 'package:helloworld/models/user.dart' as model;
import '../shared/logout_dialog.dart';

import 'detail_result.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final historyService = HistoryService();
  final userService = UserService();
  final productService = ProductService();
  model.User? currentUser;

  int _scannedCount = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // Recarga los datos del usuario y el contador
  Future<void> _initData() async {
    final user = await userService.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = user;
      });
      if (user != null) {
        _loadCount();
      }
    }
  }

  Future<void> _loadCount() async {
    final id = currentUser?.id;
    if (id != null) {
      final list = await historyService.getProductsByUser(id);
      if (mounted) {
        setState(() {
          _scannedCount = list.length;
        });
      }
    }
  }

  Future<String?> getLastScannedProduct() async {
    final id = currentUser?.id;
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
    // Obtenemos la URL actual o la por defecto
    final avatarUrl = currentUser?.avatar ?? 'lib/resources/profile.png';

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: PopupMenuButton<String>(
                // La Key asegura que el botón se refresque si el usuario cambia
                key: ValueKey(currentUser?.id ?? 'guest'),
                offset: const Offset(-40, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (value) async {
                  if (value == 'logout') {
                    showLogoutDialog(context);
                  } else if (value == 'profile') {
                    // Al usar await, esperamos a que el usuario cierre el perfil
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                    // IMPORTANTE: recargar initData al volver
                    _initData();
                  }
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
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    avatarUrl,
                    // La Key fuerza a Flutter a recargar el asset si la ruta cambia
                    key: ValueKey(avatarUrl),
                    height: 100,
                    width: 100,
                  ),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'EcoLens',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6DA67A),
                      fontFamily: 'Georgia',
                    ),
                  ),

                  const SizedBox(height: 20),
                  Image.asset(
                    'lib/resources/logo.png',
                    height: 250,
                  ),
                  const SizedBox(height: 20),

                  OutlinedButton(
                    onPressed: currentUser == null ? null : () async {
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