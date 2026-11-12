import 'package:flutter/material.dart';

/// Palet warna berdasarkan Design System "Warkop Modern POS" dari Google Stitch.
class AppColors {
  AppColors._();

  // Brand & Primary Actions
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3525CD);
  static const Color primaryLight = Color(0xFFE2DFFF);

  // Structural Rails (Dark Slate)
  static const Color slateRail = Color(0xFF0F172A);
  static const Color slateSurface = Color(0xFF1E293B);

  // Neutral Surfaces & Borders
  static const Color background = Color(0xFFF8F9FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  // Semantic Statuses
  static const Color success = Color(0xFF10B981);
  static const Color successSurface = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSurface = Color(0xFFFEF2F2);
}
