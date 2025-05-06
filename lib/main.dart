import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'welcome.dart';
import 'splash.dart';
import 'login.dart';
import 'wallet.dart';
import 'forgot.dart';
import 'help.dart';
import 'register.dart';
import 'perfil.dart';

final OutlineInputBorder defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(8.0),
  borderSide: const BorderSide(
    color: Color(0xFF007AFF),
    width: 1.0,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SibesMovility',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(

        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        primaryColor: const Color(0xFF0176fe),
        fontFamily: 'Poppins',
        inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:  Colors.white,
        errorStyle: const TextStyle(height: 0),
        enabledBorder: defaultInputBorder,
        focusedBorder: defaultInputBorder,
        errorBorder: defaultInputBorder
        ),
      ),
      
      initialRoute: '/',

      routes: {
        '/': (context) => const AuthWrapper(),
        '/welcome': (context) => const welcome(), 
        '/login': (context) => const login(),     
        '/wallet': (context) => const wallet(),  
        '/forgot': (context) => const forgot(),
        '/help': (context) => const help(), 
        '/register': (context) => const register(), 
        '/perfil': (context) => const perfil(),
        '/splash': (context) => const splash(),       
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _checkingAuth = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // duración del splash
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _isLoggedIn = user != null;
      _checkingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const splash(); // Tu widget splash animado
    }

    return _isLoggedIn ? const wallet() : const welcome();
  }
}
