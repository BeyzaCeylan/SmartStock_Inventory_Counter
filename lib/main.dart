import 'package:flutter/material.dart';
import 'pages/onboarding_screen.dart';
import 'pages/auth_selection_page.dart';
import 'pages/import_page.dart'; 
import 'pages/stock_page.dart';
import 'pages/home_page.dart'; // ✅ Ekledik
import 'pages/profile_page.dart'; // ✅ Ekledik
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
      // 👇 ROUTES aynen kalıyor, sadece HomePage ve Profile'ı ekliyoruz.
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthSelectionPage(),
        '/import': (context) => const ImportPage(), 
        '/stock': (context) => const StockPage(),
        '/home': (context) => const HomePage(), // ✅ HomePage ekledik
        '/profile': (context) => ProfileEditPage(), // ✅ Profile ekledik
      },
    );
  }
}
