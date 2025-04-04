import 'package:flutter/material.dart';
import 'pages/onboarding_screen.dart';
import 'pages/auth_selection_page.dart';

void main() {
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
