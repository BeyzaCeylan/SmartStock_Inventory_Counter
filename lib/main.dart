import 'package:flutter/material.dart';
import 'pages/onboarding_screen.dart';
import 'pages/auth_selection_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartStock',
      theme: ThemeData(
        fontFamily: 'Kanit',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF26A42C)),
        useMaterial3: true,
      ),
      // Önceki home yerine artık route sistemi kullanıyoruz
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthSelectionPage(),
      },
    );
  }
}
