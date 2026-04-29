import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:helloworld/services/user_service.dart';
import 'package:helloworld/models/user.dart' as model;
import 'package:toastification/toastification.dart';


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

  void _showErrorToast(String error) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 4),
      title: Text('$error', style: const TextStyle(fontWeight: FontWeight.bold)),
      alignment: Alignment.bottomCenter,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 600),
      icon: const Icon(Icons.error),
      showIcon: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  Future<void> _submit() async {
    try {
      UserCredential userCredential;

      //Si se ha seleccionado inciar sesión, se permite tanto mediane email como mediante Google
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
        //Si se ha seleccionado registrarse, únicamente se permite mediante email
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      //Sincronizar con bd local
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && firebaseUser.email != null) {
        final existingUser = await userRepository.findUser(firebaseUser.email!);

        //Si no existe el usuario se crea
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

        //Navegar a la ventana principal
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainScreen()),
                (route) => false,
          );
        }

      }
    } on FirebaseAuthException catch (e) {
      _showErrorToast('Incorrect username or password');
    } catch (e) {
      _showErrorToast('Authentication error');
    }
  }

  // Iniciar sesión con Google
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
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Logo y nombre
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

              // Botones de selección de método, sólo visibles en login
              if (_isLogin)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      OutlinedButton.icon(
                        onPressed: () => setState(() {
                          emailMethod = true;
                          gmailMethod = false;
                        }),
                        icon: const Icon(Icons.email_outlined),
                        label: const Text('Email'),
                        style: OutlinedButton.styleFrom(
                          //Tamaño del botón
                          minimumSize: const Size(140, 50),
                          //Borde del botón
                          side: BorderSide(
                            color: emailMethod ? const Color(0xFF6DA67A) : Colors.grey,
                            width: 2,
                          ),
                          foregroundColor: emailMethod ? const Color(0xFF6DA67A) : Colors.grey,
                        ),
                      ),
                    const SizedBox(width: 16),

                    OutlinedButton.icon(
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
                          minimumSize: const Size(140, 50),
                          side: BorderSide(
                            color: gmailMethod ? const Color(0xFF6DA67A) : Colors.grey,
                            width: 2,
                          ),
                          foregroundColor: gmailMethod ? const Color(0xFF6DA67A) : Colors.grey,
                        ),
                      ),
                  ],
                )
              else
                const Text(
                  'Register with your Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),

              const SizedBox(height: 32),

              if (emailMethod) ...[
                //En modo registro se pide el username
                if (!_isLogin) ...[
                  //controlar el tamaño
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    )
                  ),
                  const SizedBox(height: 16),
                ],
                //Campos de email y contraseña
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.mail_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                ),
                //Botón de inicio de sesión o registro
                const SizedBox(height: 45),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(300, 40),
                    backgroundColor: const Color(0xFF86C28B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_isLogin ? 'Login' : 'Sign Up'),
                ),
              ],

              //Cambiar entre inciiar sesión/ registro
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() {
                  _isLogin = !_isLogin;
                  //Si cambiamos a registro, se fuerza el método email
                  if (!_isLogin) {
                    emailMethod = true;
                    gmailMethod = false;
                  }
                }),
                child: Text(_isLogin ? 'Create an account' : 'Already have an account? Login'),
              ),
            ],
        ),
      ),
    );
  }
}
