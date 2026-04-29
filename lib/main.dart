import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:helloworld/screens/history_screen.dart';
import 'package:helloworld/screens/profile_screen.dart';
import 'firebase_options.dart';
import 'database/initDB.dart';
import 'services/user_service.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/second_screen.dart';
import 'screens/third_screen.dart';
import 'package:logger/logger.dart';


var logger = Logger(
  printer: PrettyPrinter(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicialización de la base de datos local
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    logger.d('Iniciando aplicación');
    return MaterialApp(
      title: 'Flutter MAD project',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Si Firebase detecta una sesión activa
          if (snapshot.hasData && snapshot.data != null) {
            return FutureBuilder(
              future: UserService().findUser(snapshot.data!.email!),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(child: CircularProgressIndicator(color: Color(0xFF86C28B))),
                  );
                }
                // Si el usuario existe en la BD local, vamos a la pantalla principal
                if (userSnapshot.hasData && userSnapshot.data != null) {
                  return MainScreen();
                }
                // Si no existe en la BD local (caso raro de registro incompleto), login
                return const LoginScreen();
              },
            );
          }
          // Si no hay sesión iniciada en Firebase
          return const LoginScreen();
        },
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    SplashScreen(),
    ProfileScreen(),
    ThirdScreen(),
    Center(child: Text('Achievements Screen')),
    HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _buildNavItem(IconData iconData, String label, int index, {bool isSpecial = false}) {
    final bool isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: isSpecial ? 50 : 27,
            color: isSelected ? const Color(0xFF86C28B) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isSpecial ? 20 : 12, // Solo Scan es más grande
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF86C28B) : Colors.grey,
            ),
          ),
        ],
      ),
      label: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          _buildNavItem(Icons.home_rounded, 'Home', 0),
          _buildNavItem(Icons.person_rounded, 'Profile', 1),
          _buildNavItem(Icons.qr_code_scanner_rounded, 'Scan', 2, isSpecial: true),
          _buildNavItem(Icons.emoji_events_rounded, 'Rewards', 3),
          _buildNavItem(Icons.history_rounded, 'History', 4),
        ],
      ),
    );
  }
}
