import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0A6E8A);
  static const Color primaryDark = Color(0xFF064E63);
  static const Color primaryLight = Color(0xFFE0F4F8);
  static const Color accent = Color(0xFF00BCD4);

  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color cancelled = Color(0xFF95A5A6);

  static const Color background = Color(0xFFF8FBFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF6B7C93);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color divider = Color(0xFFEAECF0);
  static const Color inputBg = Color(0xFFF0F4F8);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      fontFamily: 'Poppins',
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      ),
    );
  }
}

class Speciality {
  final String name;
  final IconData icon;
  final Color color;
  const Speciality({required this.name, required this.icon, required this.color});
}

const List<Speciality> specialities = [
  Speciality(name: 'Cardiologist', icon: Icons.favorite, color: Color(0xFFE53935)),
  Speciality(name: 'Dermatologist', icon: Icons.face, color: Color(0xFF8E24AA)),
  Speciality(name: 'Orthopedist', icon: Icons.accessibility_new, color: Color(0xFF43A047)),
  Speciality(name: 'Pediatrician', icon: Icons.child_care, color: Color(0xFFFB8C00)),
  Speciality(name: 'Neurologist', icon: Icons.psychology, color: Color(0xFF00897B)),
  Speciality(name: 'Gynecologist', icon: Icons.pregnant_woman, color: Color(0xFFD81B60)),
  Speciality(name: 'ENT Specialist', icon: Icons.hearing, color: Color(0xFF5E35B1)),
  Speciality(name: 'Dentist', icon: Icons.medical_services, color: Color(0xFF6D9E00)),
];

const List<String> timeSlots = [
  '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
  '11:00 AM', '11:30 AM', '12:00 PM',
  '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
  '04:00 PM', '04:30 PM', '05:00 PM',
];