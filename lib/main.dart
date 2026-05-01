import 'package:clinigo/constants/app_theme.dart';
import 'package:clinigo/screens/auth_screens.dart';
import 'package:clinigo/screens/main_shell.dart';
import 'package:clinigo/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinigo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),

        '/home': (context) => const MainShell(initialIndex: 0),
        '/appointments': (context) => const MainShell(initialIndex: 1),
        '/profile': (context) => const MainShell(initialIndex: 2),
      },
    );
  }
}