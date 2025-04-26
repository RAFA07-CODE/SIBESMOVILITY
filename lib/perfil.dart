import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'help.dart';
import 'wallet.dart';

class perfil extends StatefulWidget {
  const perfil({super.key});

  @override
  State<perfil> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<perfil> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isEditing = false;
  bool isChangingPassword = false;

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
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: _palette["background"],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _palette["primary"],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: () {
                          // lógica para cambiar imagen
                        },
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.email, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("correo@ejemplo.com",
                      style: TextStyle(fontSize: 16, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildEditableField(
                        label: "Nombre",
                        controller: nameController,
                        icon: Icons.person,
                        enabled: isEditing),
                    const SizedBox(height: 20),
                    _buildEditableField(
                        label: "Teléfono",
                        controller: phoneController,
                        icon: Icons.phone,
                        enabled: isEditing,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 30),
                    isEditing
                        ? ElevatedButton(
                            onPressed: () {
                              setState(() => isEditing = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Perfil actualizado')),
                              );
                            },
                            style: _buttonStyle(),
                            child: const Text("Guardar cambios"))
                        : OutlinedButton(
                            onPressed: () =>
                                setState(() => isEditing = !isEditing),
                            child: const Text("Editar perfil")),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              isChangingPassword
                  ? Column(
                      children: [
                        _buildEditableField(
                            label: "Nueva contraseña",
                            controller: newPasswordController,
                            icon: Icons.lock,
                            obscureText: true),
                        const SizedBox(height: 16),
                        _buildEditableField(
                            label: "Confirmar contraseña",
                            controller: confirmPasswordController,
                            icon: Icons.lock_outline,
                            obscureText: true),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => isChangingPassword = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Contraseña actualizada')),
                            );
                          },
                          style: _buttonStyle(),
                          child: const Text("Actualizar contraseña"),
                        )
                      ],
                    )
                  : TextButton(
                      onPressed: () =>
                          setState(() => isChangingPassword = true),
                      child: const Text("Cambiar contraseña")),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // lógica de cerrar sesión (placeholder)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Cerrar sesión"),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const wallet()));
          } else if (index == 2) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const help()));
          }
        },
        selectedItemColor: primaryColor,
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
              color: primaryColor,
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
              color: primaryColor,
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
              color: primaryColor,
            ),
            label: "Ayuda",
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(14),
      shadowColor: Colors.black12,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Campo obligatorio';
          if (label.contains("Teléfono") &&
              !RegExp(r'^\d{10}$').hasMatch(value)) {
            return 'Teléfono inválido';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _palette["primary"],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
