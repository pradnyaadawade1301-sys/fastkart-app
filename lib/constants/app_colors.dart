// lib/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Brand ─────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFFFFB300);
  static const Color primaryDark    = Color(0xFFFF8C00);
  static const Color primaryLight   = Color(0xFFFFE082);
  static const Color accent         = Color(0xFFFF5722);
  static const Color accentLight    = Color(0xFFFF8A65);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success        = Color(0xFF2E7D32);
  static const Color successLight   = Color(0xFF66BB6A);
  static const Color error          = Color(0xFFD32F2F);
  static const Color errorLight     = Color(0xFFEF5350);
  static const Color warning        = Color(0xFFF57F17);
  static const Color info           = Color(0xFF0277BD);

  // ── Veg / Non-Veg ─────────────────────────────────────────────────────────
  static const Color veg            = Color(0xFF2E7D32);
  static const Color nonVeg         = Color(0xFFD32F2F);

  // ── Neutrals ──────────────────────────────────────────────────────────────
  static const Color background     = Color(0xFFF8F5F0);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceWarm    = Color(0xFFFFF8E1);
  static const Color divider        = Color(0xFFEEEBE4);
  static const Color border         = Color(0xFFE0DBD0);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF1A1A1A);
  static const Color textSecondary  = Color(0xFF6B6560);
  static const Color textHint       = Color(0xFFADA89E);
  static const Color textOnPrimary  = Color(0xFF1A1A1A);

  // ── Map ───────────────────────────────────────────────────────────────────
  static const Color mapRoute       = Color(0xFFFF6F00);

  // ── Star ──────────────────────────────────────────────────────────────────
  static const Color star           = Color(0xFFFFB300);

  // ── Category icon bg colors ───────────────────────────────────────────────
  static const Color catFood        = Color(0xFFFF7043);
  static const Color catMovie       = Color(0xFFE91E63);
  static const Color catHotel       = Color(0xFF7C4DFF);
  static const Color catLeisure     = Color(0xFF00BCD4);
  static const Color catDelivery    = Color(0xFF4CAF50);
  static const Color catRide        = Color(0xFF2196F3);
  static const Color catBike        = Color(0xFF8BC34A);
  static const Color catTravel      = Color(0xFFFF9800);
  static const Color catGrocery     = Color(0xFF009688);
  static const Color catMore        = Color(0xFF9E9E9E);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8C00), Color(0xFFFFB300), Color(0xFFFF6F00)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
  );
}