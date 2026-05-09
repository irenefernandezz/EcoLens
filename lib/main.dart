import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:helloworld/screens/history_screen.dart';
import 'package:helloworld/screens/profile_screen.dart';
import 'package:helloworld/screens/rewards_screen.dart';
import 'firebase_options.dart';
import 'database/initDB.dart';
import 'services/user_service.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/scan_screen.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';
import 'package:toastification/toastification.dart';

// Configuración de logger
var logger = Logger(
  printer: PrettyPrinter(),
);

void main() async {
  // Necesario para inicializar la bd antes de runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicialización de la base de datos local
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Guardar el email para saber si es un inicio de sesión nuevo y evitar duplicados
  String? _lastUserEmail;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null && firebaseUser.email != null) {
        // Solo lanzamos el toast si es un nuevo login o inicio de app
        if (_lastUserEmail != firebaseUser.email) {
          final user = await UserService().findUser(firebaseUser.email!);
          if (user != null) {
            logger.d("User found: ${user.username}");
            _showWelcomeToast(user.username);
            _lastUserEmail = firebaseUser.email;
          }
        }
      } else {
        _lastUserEmail = null;
      }
    });
  }

  void _showWelcomeToast(String username) {
    logger.d("Showing welcome toast for $username");
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 4),
      title: Text('Welcome back, $username!', style: const TextStyle(fontWeight: FontWeight.bold)),
      alignment: Alignment.bottomCenter,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 600),
      icon: const Icon(Icons.waving_hand),
      showIcon: true,
      primaryColor: const Color(0xFF86C28B),
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
    logger.d('Iniciando aplicación');

    return ToastificationWrapper(
      child: OKToast(
        child: MaterialApp(
          title: 'EcoLens',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF86C28B)),
            useMaterial3: true,
          ),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator(color: Color(0xFF86C28B))),
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                return FutureBuilder(
                  future: UserService().findUser(snapshot.data!.email!),
                  builder: (context, userSnapshot) {

                    // 2. Si el usuario existe, ir a MainScreen
                    if (userSnapshot.hasData && userSnapshot.data != null) {
                      return MainScreen();
                    } else {
                      // 3. Si no existe, ir a Login (sin hacer signOut aquí para evitar errores)
                      return const LoginScreen();
                    }
                  },
                );
              } else {
                return const LoginScreen();
              }
            },
          ),
        ),
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
    const SplashScreen(),
    const ProfileScreen(),
    const ScanScreen(),
    const RewardsScreen(),
    const HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _buildNavItem(IconData iconData, String label, int index, {bool especial = false}) {
    final bool isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: especial ? 50 : 27,
            color: isSelected ? const Color(0xFF86C28B) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: especial ? 20 : 12,
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
          _buildNavItem(Icons.qr_code_scanner_rounded, 'Scan', 2, especial: true),
          _buildNavItem(Icons.emoji_events_rounded, 'Rewards', 3),
          _buildNavItem(Icons.history_rounded, 'History', 4),
        ],
      ),
    );
  }
}
