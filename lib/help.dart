import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class help extends StatelessWidget {
  const help({super.key});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copiado al portapapeles")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF0176fe);
    final Color mainTextColor = const Color(0xFF1C1C1E);
    final Color secondaryTextColor = const Color.fromARGB(255, 128, 128, 128);
    final Color backgroundColor = const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ayuda", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: mainTextColor)),
              const SizedBox(height: 10),
              Text(
                "Cómo usar la aplicación:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainTextColor),
              ),
              const SizedBox(height: 8),
              Text(
                "• Escanea tu tarjeta para ver el saldo.\n"
                "• Pulsa 'Recargar' para aumentar tu saldo.\n"
                "• Consulta tus movimientos en el historial.\n"
                "• Gestiona múltiples tarjetas fácilmente.\n"
                "• Usa el botón de ayuda si necesitas soporte.",
                style: TextStyle(fontSize: 14, color: secondaryTextColor),
              ),
              const SizedBox(height: 20),
              Text(
                "Contáctanos:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: mainTextColor),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.black87),
                title: const Text("sibesmovility@gmail.com"),
                onTap: () => _copyToClipboard(context, "sibesmovility@gmail.com"),
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.black87),
                title: const Text("+52 123 456 7890"),
                onTap: () => _copyToClipboard(context, "+52 123 456 7890"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const FeedbackDialog(),
                  );
                },
                icon: const Icon(Icons.feedback_outlined, color: Colors.white),
                label: const Text("Enviar Comentario", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  "© 2025 SibesMovility. Todos los derechos reservados.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final TextEditingController feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Envíanos tu comentario"),
      content: TextField(
        controller: feedbackController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: "Escribe aquí tu comentario...",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar"),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final feedback = feedbackController.text.trim();
            if (feedback.isNotEmpty) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("¡Gracias por tu comentario!")),
              );
            }
          },
          icon: const Icon(Icons.send, color: Colors.white),
          label: const Text("Enviar", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0176fe),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}
