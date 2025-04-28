import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class forgot extends StatefulWidget {
  const forgot({super.key});

  @override
  State<forgot> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<forgot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _palette = const {
    "primary": Color(0xFF007AFF),
    "secondary": Color(0xFF34C759),
    "accent": Color(0xFFFF9500),
    "lightBackground": Color(0xFFF2F2F7),
    "darkBackground": Color(0xFF1C1C1E),
    "textPrimary": Color(0xFF1C1C1E),
    "textSecondary": Color(0xFF8E8E93),
    "error": Color(0xFFFF3B30),
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

void _submit() async {
  if (_formKey.currentState!.validate()) {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Instrucciones enviadas al correo electrónico."),
          backgroundColor: _palette["primary"],
          duration: const Duration(seconds: 2),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Ocurrió un error. Intenta nuevamente.";
      if (e.code == 'user-not-found') {
        errorMessage = "No se encontró un usuario con ese correo.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: _palette["error"],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fondo con imagen
            Image.asset(
              'assets/images/fondo.jpg', 
              fit: BoxFit.cover,
            ),
            // Desenfoque
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
            // Contenido
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_person_rounded,
                            size: 72, color: _palette["primary"]),
                        const SizedBox(height: 16),
                        Text(
                          "¿Olvidaste tu contraseña?",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _palette["textPrimary"]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Ingresa tu correo y te enviaremos instrucciones para restablecerla.",
                          style: TextStyle(
                              fontSize: 14, color: _palette["textSecondary"]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                            Icons.email_outlined, "Correo electrónico"),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text("Enviar instrucciones",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _palette["primary"],
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 8,
                            shadowColor: _palette["primary"]!.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            "Volver al inicio de sesión",
                            style: TextStyle(
                                color: _palette["textSecondary"],
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hintText) {
    return TextFormField(
      controller: _emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu correo';
        } else if (!_isValidEmail(value)) {
          return 'Correo inválido';
        }
        return null;
      },
      style: TextStyle(color: _palette["textPrimary"]),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _palette["primary"]),
        hintText: hintText,
        hintStyle: TextStyle(color: _palette["textSecondary"]),
        filled: true,
        fillColor: _palette["lightBackground"],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }
}
