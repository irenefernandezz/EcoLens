import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:helloworld/services/user_service.dart';
import 'package:helloworld/models/user.dart' as model;

import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true;
  bool emailMethod = true;
  bool gmailMethod = false;
  final userRepository = UserService();

  Future<void> _submit() async {
    try {
      UserCredential userCredential;

      if (_isLogin) {
        if (emailMethod) {
          userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        } else {
          await _signInWithGoogle();

        }
      } else {
        // Sign Up (only Email method for now as per your UI)
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      // Sync with local database
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && firebaseUser.email != null) {
        final existingUser = await userRepository.findUser(firebaseUser.email!);
        
        if (existingUser == null) {
          String username = _usernameController.text.trim();
          if (username.isEmpty) {
            username = firebaseUser.displayName ?? firebaseUser.email!.split('@')[0];
          }

          await userRepository.saveUser(model.User(
            username: username,
            email: firebaseUser.email!,
            password: _passwordController.text.trim(),
          ));
        }

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainScreen()),
                (route) => false,
          );
        }

      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect username or password')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error')),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('lib/resources/logo.png', height: 120),
              const SizedBox(height: 20),
              const Text(
                'EcoLens',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6DA67A),
                  fontFamily: 'Georgia',
                ),
              ),
              const SizedBox(height: 40),
              
              // Botones de selección de método
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() {
                        emailMethod = true;
                        gmailMethod = false;
                      }),
                      icon: const Icon(Icons.email_outlined),
                      label: const Text('Email'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: emailMethod ? const Color(0xFF6DA67A) : Colors.grey,
                          width: 2,
                        ),
                        foregroundColor: emailMethod ? const Color(0xFF6DA67A) : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          emailMethod = false;
                          gmailMethod = true;
                        });
                        if (_isLogin) _submit();
                      },
                      icon: const Icon(Icons.g_mobiledata, size: 30),
                      label: const Text('Google'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: gmailMethod ? const Color(0xFF6DA67A) : Colors.grey,
                          width: 2,
                        ),
                        foregroundColor: gmailMethod ? const Color(0xFF6DA67A) : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              if (emailMethod) ...[
                if (!_isLogin) ...[
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.mail_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF86C28B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_isLogin ? 'Login' : 'Sign Up'),
                ),
              ],
              
              if (gmailMethod && !_isLogin)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Please use Login for Google account',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? 'Create an account' : 'Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
