import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

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
      final tag = await FlutterNfcKit.poll(timeout: const Duration(seconds: 10));
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
              const Text("Recargar saldo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Monto a recargar",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Cancelar"),
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
                            isCardScanned = false;
                          });
                          _showRechargeSuccess();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Confirmar"),
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
              Lottie.asset('assets/tarjeta.json', width: 150, height: 150),
              const SizedBox(height: 16),
              Text(
                addingNewCard ? "Añadir nueva tarjeta" : "Tarjeta actual",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (!addingNewCard) ...[
                Text(
                  "Número: ${cards[0]}",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => addingNewCard = false),
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
                          String newCard = cardNumberController.text.trim();
                          if (newCard.isNotEmpty) {
                            setState(() {
                              cards.add(newCard);
                              addingNewCard = false;
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Tarjeta guardada: $newCard")),
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
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onPressed: _isScanning ? null : _scanCard,
                        icon: const Icon(Icons.nfc, color: Colors.white),
                        label: const Text("Escanear", style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCardScanned ? accentColor : Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onPressed: isCardScanned ? _showRechargeDialog : null,
                        icon: const Icon(Icons.attach_money, color: Colors.white),
                        label: const Text("Recargar", style: TextStyle(color: Colors.white)),
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
                  icon: const Icon(Icons.credit_card, color: Colors.white),
                  label: const Text("Gestionar tarjetas", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("Historial de movimientos",
                  style: TextStyle(
                      color: mainTextColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return ListTile(
                      leading: const Icon(Icons.monetization_on_outlined, color: Colors.green),
                      title: Text("${tx['tipo']} - \$${tx['monto']}",
                          style: TextStyle(color: mainTextColor)),
                      subtitle: Text("${tx['fecha']} - Tarjeta: ${tx['tarjeta']}",
                          style: TextStyle(color: secondaryTextColor)),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const help()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const perfil()));
          }
        },
        selectedItemColor: primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: "Ayuda"),
        ],
      ),
    );
  }
}
