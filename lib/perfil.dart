import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'help.dart';
import 'wallet.dart';

class perfil extends StatefulWidget {
  const perfil({super.key});

  @override
  State<perfil> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<perfil>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController recoveryEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController accountTypeController =
      TextEditingController(text: "Estudiante");
  final AccountTypeStyle accountStyle = getAccountTypeStyle("Estudiante");
  bool _showPassword = false; // asegúrate de tener esto en tu StatefulWidget

  bool isEditing = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final _palette = const {
    "primary": Color(0xFF007AFF),
    "background": Color(0xFFF2F2F7),
    "text": Color(0xFF1C1C1E),
    "subtext": Color(0xFF8E8E93),
    "error": Color.fromARGB(255, 252, 37, 25),
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    recoveryEmailController.dispose();
    passwordController.dispose();
    accountTypeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette["background"],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Mi Perfil",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _palette["text"],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen del perfil alineada a la izquierda
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/grandfather.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Botones alineados a la derecha y uno debajo del otro
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // Acción para borrar cuenta
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _palette["error"],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: SvgPicture.asset(
                              'assets/icons/trash.svg',
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                            label: const Text("Borrar cuenta"),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();

                              // Eliminar el stack de navegación anterior y llevar a login (o wallet si prefieres)
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/wallet', (route) => false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 21, 21),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: SvgPicture.asset(
                              'assets/icons/logout.svg',
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                            label: const Text("Cerrar sesión"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: "Nombre completo",
                        controller: nameController,
                        svgAssetPath: 'assets/icons/user.svg',
                        svgColor: _palette["primary"],
                        enabled: isEditing,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Teléfono",
                        controller: phoneController,
                        svgAssetPath: 'assets/icons/phone.svg',
                        svgColor: _palette["primary"],
                        keyboardType: TextInputType.phone,
                        enabled: isEditing,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Correo electrónico",
                        controller: emailController,
                        svgAssetPath: 'assets/icons/email.svg',
                        svgColor: _palette["primary"],
                        keyboardType: TextInputType.emailAddress,
                        enabled: isEditing,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Correo de recuperación",
                        controller: recoveryEmailController,
                        svgAssetPath: 'assets/icons/email.svg',
                        svgColor: _palette["primary"],
                        keyboardType: TextInputType.emailAddress,
                        enabled: isEditing,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Contraseña",
                        controller: passwordController,
                        svgAssetPath: 'assets/icons/lock.svg',
                        svgColor: _palette["primary"],
                        isPassword: true,
                        enabled: isEditing,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: accountStyle.decoration,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: const InputDecorationTheme(
                              filled: false,
                              fillColor: Colors.transparent,
                            ),
                          ),
                          child: TextFormField(
                            controller: accountTypeController,
                            enabled: false,
                            style: TextStyle(
                              color: accountStyle.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              labelText: "Tipo de cuenta",
                              labelStyle: TextStyle(
                                color: accountStyle.textColor,
                                fontWeight: FontWeight.w600,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SvgPicture.asset(
                                  'assets/icons/user-circle.svg',
                                  width: 24,
                                  height: 24,
                                  color: accountStyle.textColor,
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                isEditing
                    ? ElevatedButton.icon(
                        onPressed: () {
                          setState(() => isEditing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Perfil actualizado')),
                          );
                        },
                        style: _primaryButtonStyle(),
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Guardar cambios"),
                      )
                    : OutlinedButton.icon(
                        onPressed: () => setState(() => isEditing = true),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _palette["primary"]!),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: SvgPicture.asset(
                          'assets/icons/edit.svg',
                          width: 20,
                          height: 20,
                          color: _palette["primary"],
                        ),
                        label: Text(
                          "Editar perfil",
                          style: TextStyle(color: _palette["primary"]),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const help()));
          } else if (index == 0) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const wallet()));
          }
        },
        selectedItemColor: _palette["primary"],
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/wallet.svg',
              width: 24,
              height: 24,
              color: Colors.grey, // o primaryColor si está seleccionado
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/wallet.svg',
              width: 24,
              height: 24,
              color: _palette["primary"],
            ),
            label: "Wallet",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/user.svg',
              width: 24,
              height: 24,
              color: Colors.grey, // o primaryColor si está seleccionado
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/user.svg',
              width: 24,
              height: 24,
              color: _palette["primary"],
            ),
            label: "Perfil",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/help.svg',
              width: 24,
              height: 24,
              color: Colors.grey, // o primaryColor si está seleccionado
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/help.svg',
              width: 24,
              height: 24,
              color: _palette["primary"],
            ),
            label: "Ayuda",
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String svgAssetPath,
    Color? svgColor,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false, // 👈 nueva propiedad
  }) {
    return Material(
      elevation: 2,
      shadowColor: _palette["primary"],
      borderRadius: BorderRadius.circular(12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: isPassword ? !_showPassword : false,
        keyboardType: keyboardType,
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
        style: TextStyle(color: _palette["primary"]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _palette["primary"]),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              svgAssetPath,
              width: 24,
              height: 24,
              color: svgColor,
            ),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: SvgPicture.asset(
                    _showPassword
                        ? 'assets/icons/eye-off.svg'
                        : 'assets/icons/eye.svg',
                    color: _palette["primary"],
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _palette["primary"],
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class AccountTypeStyle {
  final BoxDecoration decoration;
  final Color textColor;

  AccountTypeStyle({required this.decoration, required this.textColor});
}

AccountTypeStyle getAccountTypeStyle(String tipo) {
  List<Color> gradientColors;
  Color borderColor;
  Color textColor;
  Color shadowColor;

  switch (tipo.toLowerCase()) {
    case "estudiante":
      gradientColors = [Colors.white, Colors.green.shade300];
      borderColor = Colors.green;
      textColor = Colors.green.shade900;
      shadowColor = Colors.green;
      break;
    case "persona con discapacidad":
      gradientColors = [Colors.white, Colors.blue.shade300];
      borderColor = Colors.blue;
      textColor = Colors.blue.shade900;
      shadowColor = Colors.blue;
      break;
    case "adulto mayor":
      gradientColors = [Colors.white, const Color(0xFFE91E63)];
      borderColor = const Color(0xFFE91E63);
      textColor = const Color(0xFF880E4F);
      shadowColor = const Color(0xFFE91E63);
      break;
    default:
      gradientColors = [Colors.white, Colors.orange.shade300];
      borderColor = Colors.orange;
      textColor = Colors.orange.shade900;
      shadowColor = Colors.orange;
      break;
  }

  final decoration = BoxDecoration(
    border: Border.all(color: borderColor.withOpacity(0.5), width: 2),
    gradient: LinearGradient(
      colors: gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: shadowColor.withOpacity(0.3),
        blurRadius: 6,
        offset: const Offset(0, 4),
      ),
    ],
  );

  return AccountTypeStyle(decoration: decoration, textColor: textColor);
}
