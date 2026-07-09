import 'package:flutter/material.dart';

class AppConstants {
  static const String baseUrl = 'http://localhost:8080';

  static const Color primaryDark = Color(0xFF0A0E1A);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color cardDark = Color(0xFF1A1F2E);
  static const Color gold = Color(0xFFF59E0B);
  static const Color amber = Color(0xFFD97706);
  static const Color goldLight = Color(0xFFFCD34D);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color blueAccent = Color(0xFF3B82F6);
  static const Color greenAccent = Color(0xFF10B981);
  static const Color redAccent = Color(0xFFEF4444);
  static const Color greyAccent = Color(0xFF6B7280);

  static const Color singleColor = Color(0xFF3B82F6);
  static const Color doubleColor = Color(0xFF10B981);
  static const Color suiteColor = Color(0xFFF59E0B);

  static LinearGradient get goldGradient => const LinearGradient(
    colors: [gold, amber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get backgroundGradient => const LinearGradient(
    colors: [primaryDark, Color(0xFF0F172A), primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get shimmerGradient => const LinearGradient(
    colors: [
      Color(0xFF1A1F2E),
      Color(0xFF252B3E),
      Color(0xFF1A1F2E),
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
