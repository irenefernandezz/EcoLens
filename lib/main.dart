import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/second_screen.dart';
import 'screens/third_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MAD project',
      home: MainScreen(),
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
    SecondScreen(),
    ThirdScreen(),
    // TODO: Add actual screens for Achievements and History
    Center(child: Text('Achievements Screen')),
    Center(child: Text('History Screen')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //Personalizar los items del menú
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
        type: BottomNavigationBarType.fixed, // Muestra todos los iconos con sus etiquetas
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          _buildNavItem(Icons.home_rounded, 'Home', 0),
          _buildNavItem(Icons.person_rounded, 'Profile', 1),
          _buildNavItem(Icons.qr_code_scanner_rounded, 'Scan', 2, isSpecial: true), // El especial
          _buildNavItem(Icons.emoji_events_rounded, 'Rewards', 3),
          _buildNavItem(Icons.history_rounded, 'History', 4),
        ],
      ),
    );
  }
}
