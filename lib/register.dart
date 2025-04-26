import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<register>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  final _palette = const {
    "primary": Color(0xFF007AFF),
    "secondary": Color(0xFF34C759),
    "accent": Color.fromARGB(255, 247, 29, 29),
    "background": Color(0xFFF2F2F7),
    "darkBackground": Color(0xFF1C1C1E),
    "text": Color(0xFF1C1C1E),
    "subtext": Color(0xFF8E8E93),
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
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final user = userCredential.user;
        if (user == null) throw FirebaseAuthException(code: 'user-null');

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nombre': nameController.text.trim(),
          'email': emailController.text.trim(),
          'telefono': phoneController.text.trim(),
          'saldo': 0,
        });

        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error de autenticación: ${e.message}"),
            backgroundColor: _palette["error"],
          ),
        );
      } catch (e, stack) {
        debugPrint('Tipo de error: ${e.runtimeType}');
        debugPrint('Error inesperado: $e');
        debugPrint('Stacktrace: $stack');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Error inesperado. Intenta de nuevo. ${e.toString()}"),
            backgroundColor: _palette["error"],
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/fondo.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.4), // Capa oscura opcional
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: SvgPicture.asset(
                            'assets/icons/user.svg',
                            height: 50,
                            color: _palette["primary"],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text("Crear Cuenta", style: _titleStyle()),
                        const SizedBox(height: 24),
                        _buildTextFormField(Icons.person, "Nombre completo",
                            controller: nameController),
                        const SizedBox(height: 16),
                        _buildTextFormField(Icons.email, "Correo electrónico",
                            controller: emailController,
                            validator: _validateEmail),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                            Icons.phone_android, "Número de teléfono",
                            controller: phoneController,
                            validator: _validatePhone),
                        const SizedBox(height: 16),
                        _buildTextFormField(Icons.lock, "Contraseña",
                            controller: passwordController,
                            obscureText: true,
                            validator: _validatePassword),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                            Icons.lock_outline, "Confirmar contraseña",
                            controller: confirmPasswordController,
                            obscureText: true,
                            validator: _validateConfirmPassword),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: _buttonStyle(),
                          onPressed: isLoading ? null : _registerUser,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("Registrarse",
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: "Poppins")),
                        ),
                        const SizedBox(height: 24),
                        Text("O registrarse con",
                            style: TextStyle(color: _palette["subtext"])),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSocialButton(
                                FontAwesomeIcons.google, "Google"),
                            _buildSocialButton(FontAwesomeIcons.apple, "Apple"),
                          ],
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            "¿Ya tienes cuenta? Inicia sesión",
                            style: TextStyle(
                              color: _palette["subtext"],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _titleStyle() {
    return TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      fontFamily: "Poppins",
      color: _palette["text"],
    );
  }

  Widget _buildTextFormField(
    IconData icon,
    String hintText, {
    bool obscureText = false,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(fontFamily: "Roboto", color: _palette["text"]),
      keyboardType: hintText.contains("teléfono")
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _palette["primary"]),
        hintText: hintText,
        hintStyle: TextStyle(color: _palette["subtext"]?.withOpacity(0.5)),
        filled: true,
        fillColor: _palette["background"],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _palette["primary"]!, width: 2),
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty || !value.contains('@')) {
      return 'Correo inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim();
    if (phone == null ||
        phone.length != 10 ||
        !RegExp(r'^\d{10}$').hasMatch(phone)) {
      return 'Debe contener exactamente 10 dígitos';
    }
    return null;
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _palette["primary"],
      foregroundColor: _palette["background"],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 6,
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () {
              // TODO: Implementar login social
            },
      icon: FaIcon(icon, color: Colors.white, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: _palette["darkBackground"],
        foregroundColor: Colors.white,
        elevation: 5,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
