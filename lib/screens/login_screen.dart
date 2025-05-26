import 'package:feast_fit/screens/forgot_password_screen.dart';
import 'package:feast_fit/screens/screens.dart';
import 'package:feast_fit/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Ocurrió un error. Intenta de nuevo.";

        print("Firebase Auth Error Code: ${e.code}");
        print("Firebase Auth Error Message: ${e.message}");

        if (e.code == 'user-not-found') {
          errorMessage = 'No existe usuario con este correo electrónico.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Contraseña incorrecta.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'El correo electrónico no es válido.';
        } else if (e.code == 'user-disabled') {
          errorMessage = 'Este usuario ha sido deshabilitado.';
        } else {
          errorMessage = 'Error: ${e.message}';
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error de inicio de sesión'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Configurar Google Sign In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Si el usuario cancela el inicio de sesión
      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Obtener detalles de autenticación del request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crear credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión con Firebase usando la credencial de Google
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Obtener el usuario actual
      final User? user = userCredential.user;

      if (user != null) {
        // Obtener el documento del usuario en Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Crear un mapa para los datos del usuario
        final userData = {
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
          'provider': 'google',
          'weight': "0",
          'height': "",
          'sportActivity': "",
          'isAdmin': false,
          'chartData': [],
        };

        // Si el usuario ya existe, no sobrescribir el campo 'meals'
        if (userDoc.exists) {
          final existingData = userDoc.data() as Map<String, dynamic>;
          if (existingData.containsKey('meals')) {
            userData['meals'] = existingData['meals'];
          }
        }

        // Guardar o actualizar la información básica del usuario en Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
              userData,
              SetOptions(merge: true),
            );

        // Navegar a la pantalla principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      print('Error durante el inicio de sesión con Google: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error de inicio de sesión'),
          content:
              Text('No se pudo iniciar sesión con Google: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnimatedGradientBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 200, height: 200),
                const SizedBox(height: 40),
                const Text('FeastFit',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Correo electrónico',
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: const TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor ingresa tu correo'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: const TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text('¿Olvidaste tu contraseña?',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              const Color.fromARGB(255, 85, 57, 15),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Iniciar Sesión',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white70,
                              thickness: 1,
                              indent: 20,
                              endIndent: 10,
                            ),
                          ),
                          Text(
                            'O',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white70,
                              thickness: 1,
                              indent: 10,
                              endIndent: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : _signInWithGoogle,
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          'Continuar con Google',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿No tienes una cuenta?',
                              style: TextStyle(color: Colors.white70)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen()),
                              );
                            },
                            child: const Text('Regístrate',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
