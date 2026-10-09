import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  AppColors._();

  static final RxBool _isDark = true.obs;


  static void setTheme({required bool dark}) {
    _isDark.value = dark;
  }

  static bool get isDark => _isDark.value;

  // ─── Backgrounds ────────────────────────────────────────────────────────
  static Color get scaffoldBg =>
      isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF2F2FF);
  static Color get surfaceBg =>
      isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFFFF);
  static Color get cardBg =>
      isDark ? const Color(0xFF1E1E30) : const Color(0xFFF8F8FF);
  static Color get inputBg =>
      isDark ? const Color(0xFF0F0F1A) : const Color(0xFFEEEEFF);

  // ─── Borders ────────────────────────────────────────────────────────────
  static Color get border =>
      isDark ? const Color(0xFF2E2E45) : const Color(0xFFDDDDF0);
  static Color get borderSubtle =>
      isDark ? const Color(0xFF3E3E5E) : const Color(0xFFCCCCEE);

  // ─── Text ───────────────────────────────────────────────────────────────
  static Color get textPrimary =>
      isDark ? Colors.white : const Color(0xFF1A1A2E);
  static Color get textSecondary =>
      isDark ? const Color(0xFF8B8FA8) : const Color(0xFF6B6B8A);
  static Color get textMuted =>
      isDark ? const Color(0xFF5A5A7A) : const Color(0xFF9898B8);

  // ─── Accent (unchanged for both themes) ─────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF48C6EF);
  static const Color high = Color(0xFFFF6B6B);
  static const Color medium = Color(0xFFFFBE0B);
  static const Color low = Color(0xFF4ECDC4);
}
