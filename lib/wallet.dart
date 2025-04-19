import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
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
  final Color primaryColor = const Color(0xFF0176fe);
  final Color secondaryColor = const Color(0xFF34C759);
  final Color accentColor = const Color(0xFFFF9500);
  final Color backgroundColor = const Color(0xFFF2F2F7);
  final Color mainTextColor = const Color(0xFF1C1C1E);
  final Color secondaryTextColor = const Color.fromARGB(255, 206, 206, 206);

  bool _isScanning = false;

  void _showScanSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/nfc_success.json', width: 120, height: 120),
            const SizedBox(height: 12),
            const Text("Tarjeta escaneada con éxito")
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      setState(() {
        _isScanning = false;
      });
    });
  }

  void _showRechargeDialog() {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Recargar saldo"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Monto a recargar",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.of(context).pop();
                setState(() {
                  balance += amount;
                  transactions.insert(0, {
                    'tipo': 'Recarga',
                    'tarjeta': '1234 5678 9012 3456',
                    'fecha': DateFormat('dd/MM/yyyy – hh:mm a')
                        .format(DateTime.now()),
                    'monto': amount.toStringAsFixed(2)
                  });
                });
                _showRechargeSuccess();
              }
            },
            child: const Text("Confirmar"),
          ),
        ],
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
            Lottie.asset('assets/success.json', width: 120, height: 120),
            const SizedBox(height: 12),
            const Text("Saldo recargado con éxito")
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
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
              Text(
                "Mi Tarjeta",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
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
                                style: TextStyle(color: secondaryTextColor)),
                            const SizedBox(height: 10),
                            Text(
                              "\$${balance.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold),
                            ),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        onPressed: _isScanning
                            ? null
                            : () {
                                setState(() => _isScanning = true);
                                _showScanSuccessDialog();
                              },
                        icon: const Icon(Icons.nfc, color: Colors.white),
                        label: const Text("Escanear",
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        onPressed: _showRechargeDialog,
                        icon:
                            const Icon(Icons.attach_money, color: Colors.white),
                        label: const Text("Recargar",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.credit_card, color: Colors.white),
                label: const Text("Gestionar tarjetas"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainTextColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      leading: const Icon(Icons.monetization_on_outlined,
                          color: Colors.green),
                      title: Text("${tx['tipo']} - \$${tx['monto']}",
                          style: TextStyle(color: mainTextColor)),
                      subtitle: Text(
                          "${tx['fecha']} - Tarjeta: ${tx['tarjeta']}",
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
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const help()));
          }

          if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => perfil()));
          }
        },
        selectedItemColor: primaryColor,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(
              icon: Icon(Icons.help_outline), label: "Ayuda"),
        ],
      ),
    );
  }
}
