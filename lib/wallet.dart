import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:flutter/services.dart';

import 'help.dart';
import 'perfil.dart';

class wallet extends StatefulWidget {
  const wallet({super.key});

  @override
  State<wallet> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<wallet> {
  double balance = 45.00;
  List<Map<String, String>> transactions = [];
  bool _isScanning = false;
  bool isCardScanned = false;
  List<String> cards = ["1234 5678 9012 3456"];
  String? selectedCard;

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

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/tarjeta.json', width: 100, height: 100),
              const SizedBox(height: 10),
              const Text("Recargar saldo",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Monto a recargar",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Cancelar",
                          style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(amountController.text);
                        if (amount != null && amount > 0) {
                          Navigator.of(context).pop();
                          setState(() {
                            balance += amount;
                            transactions.insert(0, {
                              'tipo': 'Recarga',
                              'tarjeta': cards[0],
                              'fecha': DateFormat('dd/MM/yyyy – hh:mm a')
                                  .format(DateTime.now()),
                              'monto': amount.toStringAsFixed(2)
                            });
                            isCardScanned = true;
                          });
                          _showRechargeSuccess();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Confirmar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  void _showManageCardsDialog() {
    final TextEditingController cardNumberController = TextEditingController();
    bool addingNewCard = false;

    void _showError(BuildContext context, String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }

    String? selectedCard = cards.isNotEmpty ? cards[0] : null;

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
                Lottie.asset('assets/tarjeta.json', width: 90, height: 90),
                const SizedBox(height: 16),
                Text(
                  addingNewCard ? "Añadir nueva tarjeta" : "Tarjeta actual",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (!addingNewCard) ...[
                  const Text(
                    "Selecciona una tarjeta",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  ...cards.map((card) => GestureDetector(
                        onTap: () => setState(() => selectedCard = card),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selectedCard == card
                                ? Colors.blue.shade50
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedCard == card
                                  ? primaryColor
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: card,
                                groupValue: selectedCard,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCard = value!;
                                  });
                                },
                                activeColor: primaryColor,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Tarjeta terminada en",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                  Text(
                                    "**** **** **** ${card.substring(card.length - 4)}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => addingNewCard = true),
                      icon: const Icon(Icons.add),
                      label: const Text("Añadir nueva tarjeta"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ] else ...[
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
                            errorText:
                                expError?.isNotEmpty == true ? expError : null,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) {
                            setState(() {
                              expError = '';
                              if (value.length != 5 || !value.contains('/')) {
                                expError = 'Formato inválido. Usa MM/AA';
                                return;
                              }

                              final parts = value.split('/');
                              final mes = int.tryParse(parts[0]);
                              final anio = int.tryParse('20${parts[1]}');

                              if (mes == null || mes < 1 || mes > 12) {
                                expError = 'Mes inválido';
                                return;
                              }

                              if (anio == null) {
                                expError = 'Año inválido';
                                return;
                              }

                              final now = DateTime.now();
                              final expiryDate = DateTime(anio, mes + 1, 0);

                              if (expiryDate.isBefore(now)) {
                                expError = 'La tarjeta está expirada.';
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: cvvController,
                          decoration: InputDecoration(
                            labelText: "CVV",
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
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              setState(() => addingNewCard = false),
                          child: const Text("Cancelar"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: const BorderSide(color: Colors.black12),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            String card = cardNumberController.text
                                .replaceAll(RegExp(r'\D'), '');
                            String holder = cardHolderController.text.trim();
                            String exp = expirationDateController.text.trim();
                            String cvv = cvvController.text.trim();

                            setState(() {
                              cardError =
                                  holderError = expError = cvvError = null;

                              if (card.length != 16)
                                cardError = "Debe tener 16 dígitos.";
                              if (holder.length < 5)
                                holderError = "Nombre muy corto.";
                              if (cvv.length < 3) cvvError = "CVV inválido.";
                            });

                            if (cardError == null &&
                                holderError == null &&
                                expError == null &&
                                cvvError == null) {
                              setState(() {
                                cards.add(card);
                                selectedCard = card;
                                addingNewCard = false;
                              });

                              cardNumberController.clear();
                              cardHolderController.clear();
                              expirationDateController.clear();
                              cvvController.clear();

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Tarjeta guardada: $card")),
                              );
                            }
                          },
                          child: const Text("Guardar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      text: 'Rafael',
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
                            Text("\$${balance.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Roboto")),
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
                  onPressed: _showManageCardsDialog,
                  icon: SvgPicture.asset(
                    'assets/icons/credit-card.svg',
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  label: const Text("Gestionar tarjetas",
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
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isRecarga = tx['tipo'] == 'Recarga';
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isRecarga
                              ? [Colors.white, secondaryColor]
                              : [Colors.red.withOpacity(0.05), Colors.red],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: SvgPicture.asset(
                            'assets/icons/${isRecarga ? 'dollar-sign' : 'dollar-sign'}.svg',
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
                            color: Colors.green[900],
                            fontFamily: 'Roboto',
                          ),
                        ),
                        subtitle: Text(
                          "${tx['fecha']}\nTarjeta: ${tx['tarjeta']}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[800],
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
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
