import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Column(
        children: [
          Icon(
            Icons.logout_rounded,
            color: Color(0xFF6DA67A),
            size: 50,
          ),
          SizedBox(height: 15),
          Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        'Do you want to log out of the app?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF86C28B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            // Guardamos el navigator en una variable antes de la operación asíncrona
            final navigator = Navigator.of(context, rootNavigator: true);
            
            try {
              // Cerramos el diálogo primero
              navigator.pop();
              
              // Cerramos sesión en Firebase
              await FirebaseAuth.instance.signOut();

              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            } catch (e) {
              debugPrint('Error during logout: $e');
            }
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const LogoutDialog();
    },
  );
}
