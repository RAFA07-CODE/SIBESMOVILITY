import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _LoginPageState();
}

class _LoginPageState extends State<login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

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
  final Color secondaryTextColor = const Color.fromARGB(255, 206, 206, 206);
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
            Image.network(
              'https://images.unsplash.com/photo-1491895200222-0fc4a4c35e18?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              fit: BoxFit.cover,
            ),

            // Filtro borroso + capa translúcida
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
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
                          hint: "Correo electrónico", icon: Icons.email),
                      const SizedBox(height: 20),
                      _buildTextField(
                          hint: "Contraseña",
                          icon: Icons.lock,
                          isPassword: true),
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
                        onPressed: () {
                          Navigator.pushNamed(context, '/wallet');
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
                        child: const Text("Iniciar Sesión",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
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
                            color: mainTextColor,
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
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      style: TextStyle(color: mainTextColor),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryColor),
        hintText: hint,
        hintStyle: TextStyle(color: secondaryTextColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: secondaryTextColor),
          borderRadius: BorderRadius.circular(14),
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
