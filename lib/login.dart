import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _LoginPageState();
}

class _LoginPageState extends State<login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🎨 Colores según paleta
  final Color primaryColor = const Color(0xFF0176fe);
  final Color secondaryColor = const Color(0xFF34C759);
  final Color accentColor = const Color(0xFFFF9500);
  final Color backgroundColor = const Color(0xFFF2F2F7);
  final Color darkBackground = const Color(0xFF1C1C1E);
  final Color mainTextColor = const Color(0xFF1C1C1E);
  final Color secondaryTextColor = const Color(0xFF8E8E93);
  final Color errorColor = const Color(0xFFFF3B30);

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fondo con imagen desde URL
            Image.asset(
              'assets/images/fondo.jpg',
              fit: BoxFit.cover,
            ),
            // Filtro borroso + capa translúcida
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                color: Colors.white.withOpacity(0.1),
              ),
            ),

            // Contenido principal
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/navi.png',
                              height: 100, // Ajusta el tamaño
                            ),
                            const SizedBox(
                                height: 8), // Espacio entre imagen y texto
                            Text(
                              'SIBESMOVILITY',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                color: Color(0xFF0176fe),
                                fontFamily: 'Poppins',
                                shadows: [
                                  Shadow(
                                    color: Color.fromARGB(66, 151, 193, 255),
                                    offset: Offset(0, 6),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Inicia Sesión",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: mainTextColor,
                          fontFamily: "Poppins",
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        hintText: "Correo electrónico",
                        prefix: SvgPicture.asset(
                          'assets/icons/email.svg',
                          color:
                              primaryColor, // O cualquier ícono personalizado
                        ),
                        controller: _emailController,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        hintText: "Contraseña",
                        prefix: SvgPicture.asset(
                          'assets/icons/lock.svg',
                          color:
                              primaryColor, // O cualquier ícono personalizado
                        ),
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot');
                          },
                          child: Text(
                            "¿Olvidaste tu contraseña?",
                            style: TextStyle(color: mainTextColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();

                          if (email.isEmpty || password.isEmpty) {
                            // Mostrar error si los campos están vacíos
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Por favor, completa todos los campos.'),
                                backgroundColor: errorColor,
                              ),
                            );
                            return;
                          }

                          try {
                            final userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password);

                            final uid = userCredential.user!.uid;

                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .get();

                            Navigator.pushNamed(context, '/wallet');
                          } on FirebaseAuthException catch (e) {
                            String errorMessage;

                            switch (e.code) {
                              case 'invalid-email':
                                errorMessage =
                                    'El correo electrónico no es válido.';
                                break;
                              case 'user-not-found':
                                errorMessage =
                                    'No existe una cuenta con este correo.';
                                break;
                              case 'wrong-password':
                                errorMessage = 'La contraseña es incorrecta.';
                                break;
                              case 'user-disabled':
                                errorMessage =
                                    'Esta cuenta ha sido deshabilitada.';
                                break;
                              default:
                                errorMessage = 'Ocurrió un error: ${e.message}';
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: errorColor,
                              ),
                            );
                          } catch (e) {
                            // Cualquier otro error no relacionado directamente con FirebaseAuth
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error inesperado: $e'),
                                backgroundColor: errorColor,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black38,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/login.svg',
                              width: 24,
                              height: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Iniciar Sesión",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text("O continúa con",
                          style: TextStyle(color: mainTextColor)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _socialButton(FontAwesomeIcons.google, "Google"),
                          _socialButton(FontAwesomeIcons.apple, "Apple"),
                        ],
                      ),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          "¿No tienes cuenta? Regístrate",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required Widget prefix,
    TextEditingController? controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_showPassword : false,
      style: TextStyle(color: mainTextColor),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: prefix,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: SvgPicture.asset(
                  _showPassword
                      ? 'assets/icons/eye-off.svg'
                      : 'assets/icons/eye.svg',
                  color: primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              )
            : null,
        hintText: hintText,
        hintStyle: TextStyle(color: mainTextColor.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {
        // lógica para login social
      },
      icon: FaIcon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: darkBackground,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
