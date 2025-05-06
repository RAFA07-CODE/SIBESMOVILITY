import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'help.dart';
import 'perfil.dart';

class wallet extends StatefulWidget {
  const wallet({super.key});

  @override
  State<wallet> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<wallet> {
  List<Map<String, String>> transactions = [];
  bool _isScanning = false;
  bool isCardScanned = false;
  List<String> cards = ["1234 5678 9012 3456"];
  String? selectedCard;
  String? selectedMetodo; // Added variable to track selected payment method

  String userName = '';
  double balance = 0.0;
  bool isLoading = true;

  late String userId;

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController expirationController = TextEditingController();
  final TextEditingController expirationDateController =
      TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  String? cardError, holderError, expError, cvvError;

  final Color primaryColor = const Color(0xFF0176fe);
  final Color secondaryColor = const Color(0xFF34C759);
  final Color accentColor = const Color(0xFFFF9500);
  final Color backgroundColor = const Color(0xFFF2F2F7);
  final Color mainTextColor = const Color(0xFF1C1C1E);
  final Color secondaryTextColor = const Color.fromARGB(255, 150, 150, 150);

  Future<void> _scanCard() async {
    setState(() => _isScanning = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/animation.json', width: 200, height: 200),
            const SizedBox(height: 12),
            const Text("Escaneando tarjeta...")
          ],
        ),
      ),
    );

    try {
      final tag =
          await FlutterNfcKit.poll(timeout: const Duration(seconds: 10));
      await Future.delayed(const Duration(seconds: 1));
      await FlutterNfcKit.finish();

      if (context.mounted) {
        Navigator.of(context).pop();
        _showScanSuccessDialog();
        setState(() => isCardScanned = true);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showScanErrorDialog();
      }
    }

    setState(() => _isScanning = false);
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            userName = doc.data()!['nombre'] ?? '';
            balance = (doc.data()!['saldo'] ?? 0).toDouble();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

@override
void initState() {
  super.initState();
  fetchUserData();

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    userId = user.uid;
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }
}


  String _formatFecha(Timestamp? timestamp) {
    if (timestamp == null) return 'Fecha desconocida';
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  void _showScanSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/nfc_success1.json', width: 200, height: 200),
            const SizedBox(height: 8),
            const Text("Tarjeta escaneada con éxito")
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) Navigator.of(context).pop();
    });
  }

  void _showScanErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/error.json', width: 200, height: 200),
            const SizedBox(height: 8),
            const Text("No se pudo leer la tarjeta.")
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) Navigator.of(context).pop();
    });
  }

  void _showRechargeDialog() {
    final TextEditingController amountController = TextEditingController();
    final currencyFormatter =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 30,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/tarjeta.json', width: 100, height: 100),
                const SizedBox(height: 16),
                const Text(
                  "Recargar saldo",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(), // 👈 Formateador especial
                  ],
                  decoration: InputDecoration(
                    prefixText: "\$",
                    labelText: "Monto a recargar",
                    labelStyle: const TextStyle(fontSize: 16),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final enteredText = amountController.text
                              .replaceAll(RegExp(r'[^\d]'), '');
                          final amount =
                              (double.tryParse(enteredText) ?? 0.0) / 100;

                          if (amount > 0) {
                            Navigator.of(context).pop();

                            final userId =
                                FirebaseAuth.instance.currentUser!.uid;

                            try {
                              final userRef = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId);

                              final userSnapshot = await userRef.get();
                              if (userSnapshot.exists) {
                                final currentBalance =
                                    userSnapshot.data()?['saldo'] ?? 0.0;
                                await userRef.update({
                                  'saldo': currentBalance + amount,
                                });
                              }

                              await userRef.collection('transacciones').add({
                                'tipo': 'Recarga',
                                'tarjeta_id': 'selectedCardId',
                                'fecha': Timestamp.now(),
                                'monto': amount,
                              });

                              _showRechargeSuccess();
                            } catch (e) {
                              print('Error al recargar saldo: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Error al recargar saldo. Inténtalo de nuevo.')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Confirmar",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRechargeSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/succes.json', width: 100, height: 100),
            const SizedBox(height: 12),
            const Text("Saldo recargado con éxito")
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) Navigator.of(context).pop();
    });
  }

  void _editarMetodoPago(String id, Map<String, dynamic> data) {
    // Mostrar un modal de edición o navegar a una pantalla de edición
  }

  void _borrarMetodoPago(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('metodos_pago')
        .doc(id)
        .delete();
  }

  void _showMetodosDePagoModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 30,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Métodos de Pago",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('metodos_pago')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final metodos = snapshot.data!.docs;
                  if (metodos.isEmpty) {
                    return const Text('No tienes métodos de pago registrados.');
                  }
                  return Column(
                    children: metodos.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final tipo = data['tipo'] ?? '';
                      final descripcion = data['descripcion'] ?? '';
                      final metodoId = doc.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _getMetodoIcon(tipo),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                descripcion,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Radio<String>(
                              value: metodoId,
                              groupValue: selectedMetodo,
                              onChanged: (value) {
                                setState(() {
                                  selectedMetodo = value!;
                                });
                              },
                            ),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/edit.svg',
                                width: 20,
                                height: 20,
                                color: primaryColor,
                              ),
                              onPressed: () {
                                _editarMetodoPago(metodoId, data);
                              },
                            ),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/trash.svg',
                                width: 20,
                                height: 20,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _borrarMetodoPago(metodoId);
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showAgregarMetodoModal,
                icon: const Icon(Icons.add),
                label: const Text("Agregar método de pago"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAgregarMetodoModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 30,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Agregar método de pago",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/cash.svg',
                width: 24,
                height: 24,
                color: secondaryColor,
              ),
              title: const Text('Dinero'),
              onTap: () => _agregarMetodo('dinero', 'Saldo en cuenta'),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/credit-card.svg',
                width: 24,
                height: 24,
                color: primaryColor,
              ),
              title: const Text('Tarjeta de crédito o débito'),
              onTap: _showAgregarTarjetaForm,
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/truck.svg',
                width: 24,
                height: 24,
                color: Colors.yellow[900],
              ),
              title: const Text('Mercado Pago'),
              onTap: () => _agregarMetodo('mercado_pago', 'Mercado Pago'),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/storefront.svg',
                width: 24,
                height: 24,
                color: Colors.red,
              ),
              title: const Text('OXXO'),
              onTap: () => _agregarMetodo('oxxo', 'Pago en OXXO'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgregarTarjetaForm() {
    final TextEditingController cardNumberController = TextEditingController();
    final TextEditingController cardHolderController = TextEditingController();
    final TextEditingController expirationDateController =
        TextEditingController();
    final TextEditingController cvvController = TextEditingController();

    String? cardError;
    String? holderError;
    String? expError;
    String? cvvError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 30,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Agregar Tarjeta",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: cardNumberController,
                  decoration: InputDecoration(
                    labelText: "Número de tarjeta",
                    errorText: cardError,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(19),
                    CardNumberInputFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cardHolderController,
                  decoration: InputDecoration(
                    labelText: "Nombre del titular",
                    errorText: holderError,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: expirationDateController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          ExpirationDateFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: "MM/AA",
                          hintText: "MM/AA",
                          errorText: expError,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: cvvController,
                        decoration: InputDecoration(
                          labelText: "CVV",
                          hintText: '123',
                          errorText: cvvError,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      cardError = holderError = expError = cvvError = null;

                      if (cardNumberController.text
                              .replaceAll(RegExp(r'\D'), '')
                              .length !=
                          16) cardError = "Debe tener 16 dígitos.";
                      if (cardHolderController.text.trim().isEmpty)
                        holderError = "Nombre requerido.";
                      if (expirationDateController.text.length != 5 ||
                          !expirationDateController.text.contains('/'))
                        expError = "Formato inválido (MM/AA)";
                      if (cvvController.text.length != 3)
                        cvvError = "CVV inválido.";
                    });

                    if (cardError == null &&
                        holderError == null &&
                        expError == null &&
                        cvvError == null) {
                      final numero = cardNumberController.text
                          .replaceAll(RegExp(r'\D'), '');
                      final descripcion =
                          "Tarjeta terminada en ${numero.substring(numero.length - 4)}";

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('metodos_pago')
                          .add({
                        'tipo': 'tarjeta',
                        'descripcion': descripcion,
                        'detalles': {
                          'numero': numero,
                          'holder': cardHolderController.text.trim(),
                          'expiracion': expirationDateController.text.trim(),
                          'cvv': cvvController.text.trim(),
                        },
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      Navigator.pop(context); // Cerrar el modal

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Tarjeta agregada exitosamente')),
                      );
                    }
                  },
                  child: const Text("Guardar tarjeta"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    backgroundColor: secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _agregarMetodo(String tipo, String descripcion) async {
    Navigator.pop(context); // Cerrar modal de opciones

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('metodos_pago')
        .add({
      'tipo': tipo,
      'descripcion': descripcion,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Método de pago agregado: $descripcion')),
    );
  }

  Widget _getMetodoIcon(String tipo) {
    switch (tipo) {
      case 'dinero':
        return SvgPicture.asset(
          'assets/icons/cash.svg',
          width: 24,
          height: 24,
          color: secondaryColor,
        );
      case 'tarjeta':
        return SvgPicture.asset(
          'assets/icons/credit-card.svg',
          width: 24,
          height: 24,
          color: primaryColor,
        );
      case 'mercado_pago':
        return SvgPicture.asset(
          'assets/icons/truck.svg',
          width: 24,
          height: 24,
          color: Colors.yellow[900],
        );
      case 'oxxo':
        return SvgPicture.asset(
          'assets/icons/storefront.svg',
          width: 24,
          height: 24,
          color: Colors.red,
        );
      default:
        return SvgPicture.asset(
          'assets/icons/default-payment.svg',
          width: 24,
          height: 24,
          color: Colors.grey,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Mi Tarjeta",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: mainTextColor,
                  )),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'Bienvenido ',
                      style:
                          TextStyle(color: primaryColor, fontFamily: "Nunito"),
                    ),
                    TextSpan(
                      text: userName.isEmpty ? '...' : userName,
                      style: TextStyle(
                          color: Colors.blue[900],
                          fontFamily: "Nunito"), // Azul oscuro
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 6,
                      color: primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Saldo disponible",
                                style: TextStyle(color: backgroundColor)),
                            const SizedBox(height: 10),
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .snapshots(), // Escucha cambios en el usuario
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator(); // O un loading
                                }

                                final userData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                final balance = userData['saldo'] ?? 0.0;

                                return Text(
                                  "\$${balance.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Roboto",
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        onPressed: _isScanning ? null : _scanCard,
                        icon: const Icon(Icons.nfc, color: Colors.white),
                        label: const Text("Escanear",
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isCardScanned ? accentColor : Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        onPressed: isCardScanned ? _showRechargeDialog : null,
                        icon: SvgPicture.asset(
                          'assets/icons/dollar-sign.svg',
                          width: 20,
                          height: 20,
                          color: Colors
                              .white, // o primaryColor si está seleccionado
                        ),
                        label: const Text("Recargar",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showMetodosDePagoModal,
                  icon: SvgPicture.asset(
                    'assets/icons/credit-card.svg',
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  label: const Text("Metodos de pago",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Historial de movimientos",
                style: TextStyle(
                  fontSize: 20,
                  color: mainTextColor,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId) // 👈 Tu ID de usuario actual
                      .collection('transacciones')
                      .orderBy('fecha',
                          descending:
                              true) // Opcional: ordena más reciente primero
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('No hay transacciones todavía.'));
                    }

                    final transactions = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final isRecarga = tx['tipo'] == 'Recarga';

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isRecarga
                                  ? secondaryColor.withOpacity(0.5)
                                  : Colors.red.withOpacity(0.5),
                              width: 2,
                            ),
                            gradient: LinearGradient(
                              colors: isRecarga
                                  ? [Colors.white, secondaryColor]
                                  : [Colors.white, Colors.red],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            leading: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                border: Border.all(
                                  color:
                                      isRecarga ? secondaryColor : Colors.red,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset(
                                'assets/icons/${isRecarga ? 'dollar-sign' : 'arrow-down'}.svg',
                                width: 32,
                                height: 32,
                                color: isRecarga ? secondaryColor : Colors.red,
                              ),
                            ),
                            title: Text(
                              "${tx['tipo']} - \$${tx['monto']}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: isRecarga
                                    ? Colors.green[900]
                                    : Colors.red[900],
                                fontFamily: 'Roboto',
                              ),
                            ),
                            subtitle: Text(
                              "${_formatFecha(tx['fecha'])}\nTarjeta: ${tx['tarjeta_id'] ?? 'N/A'}",
                              style: TextStyle(
                                fontSize: 14,
                                color: isRecarga
                                    ? Colors.green[800]
                                    : Colors.red[800],
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const help()));
          } else if (index == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const perfil()));
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
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limita a 16 dígitos
    final limitedDigits = digits.length > 16 ? digits.substring(0, 16) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < limitedDigits.length; i++) {
      buffer.write(limitedDigits[i]);
      if ((i + 1) % 4 == 0 && i != limitedDigits.length - 1) buffer.write('-');
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpirationDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);

    String formatted = digits;
    if (digits.length >= 3) {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter =
      NumberFormat.currency(locale: 'es_MX', symbol: '');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final number = double.parse(digitsOnly) / 100;

    final newText = _formatter.format(number);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
