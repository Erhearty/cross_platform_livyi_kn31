import 'package:flutter/material.dart';
import 'colors.dart';

// Кольори що автоматично адаптуються до поточної теми (light / dark).
// Використовуйте через context замість жорстко закодованих AppColors.*
extension AppThemeExt on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ── Фони ────────────────────────────────────────────────────────────────
  Color get bg         => isDark ? const Color(0xFF0C0C1C) : AppColors.background;
  Color get surface    => isDark ? const Color(0xFF1C1C32) : Colors.white;
  Color get cardBg     => isDark ? const Color(0xFF15152A) : Colors.white;
  Color get inactiveBg => isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade100;

  // ── Текст ───────────────────────────────────────────────────────────────
  Color get textPrimary   => isDark ? const Color(0xFFE2E2F5) : AppColors.textPrimary;
  Color get textSecondary => isDark ? const Color(0xFF9898B8) : AppColors.textSecondary;
  Color get textHint      => isDark ? const Color(0xFF505070) : AppColors.textHint;

  // ── Розділювачі та межі ─────────────────────────────────────────────────
  Color get divider    => isDark ? const Color(0xFF26264A) : AppColors.divider;
  Color get shadowCol  => isDark ? Colors.black54            : AppColors.cardShadow;
}
