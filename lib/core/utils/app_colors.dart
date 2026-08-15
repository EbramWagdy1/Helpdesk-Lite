import 'package:flutter/material.dart';

class AppColors {
  // ============================================================
  // Brand Colors
  // ============================================================

  /// Main brand blue - inspired by the app logo
  static const Color primary = Color(0xFF1769FF);

  /// Bright cyan/blue used for highlights
  static const Color primaryLight = Color(0xFF29C5F6);

  /// Deep navy blue for strong contrast
  static const Color primaryDark = Color(0xFF123B9B);

  /// Soft blue accent
  static const Color primaryAccent = Color(0xFF5CA8FF);

  // ============================================================
  // Secondary / Accent Colors
  // ============================================================

  /// Cyan from the logo
  static const Color secondary = Color(0xFF29C5F6);

  /// Fresh green used for successful tickets / status
  static const Color accent = Color(0xFF20C878);

  /// Yellow/orange notification accent from the logo
  static const Color notification = Color(0xFFFFC629);

  // ============================================================
  // Gradients
  // ============================================================

  /// Main brand gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF123B9B),
      Color(0xFF1769FF),
      Color(0xFF29C5F6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Blue gradient for cards
  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFF1769FF),
      Color(0xFF123B9B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft gradient for backgrounds
  static const LinearGradient softGradient = LinearGradient(
    colors: [
      Color(0xFFEFF7FF),
      Color(0xFFF8FCFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cyan highlight gradient
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [
      Color(0xFF29C5F6),
      Color(0xFF1769FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // Background & Surface
  // ============================================================

  static const Color background = Color(0xFFF6F9FD);

  static const Color surface = Color(0xFFFFFFFF);

  static const Color surfaceVariant = Color(0xFFEEF5FC);

  static const Color cardBackground = Color(0xFFFFFFFF);

  // ============================================================
  // Text Colors
  // ============================================================

  /// Main text - deep navy
  static const Color textPrimary = Color(0xFF102A56);

  /// Secondary text
  static const Color textSecondary = Color(0xFF64748B);

  /// Muted text
  static const Color textMuted = Color(0xFF94A3B8);

  /// Text on dark/primary backgrounds
  static const Color textLight = Color(0xFFFFFFFF);

  // ============================================================
  // Border & Divider
  // ============================================================

  static const Color border = Color(0xFFDCE7F3);

  static const Color borderFocused = Color(0xFF1769FF);

  static const Color divider = Color(0xFFEAF0F6);

  // ============================================================
  // Status Colors
  // ============================================================

  /// Successful operation / Resolved ticket
  static const Color success = Color(0xFF20C878);

  static const Color successLight = Color(0xFFDDF8EC);

  /// Pending / Waiting
  static const Color warning = Color(0xFFFFB020);

  static const Color warningLight = Color(0xFFFFF3D6);

  /// Error / Failed
  static const Color error = Color(0xFFEF4444);

  static const Color errorLight = Color(0xFFFEE2E2);

  /// Information
  static const Color info = Color(0xFF2196F3);

  static const Color infoLight = Color(0xFFE0F2FE);

  // ============================================================
  // Ticket Priority
  // ============================================================

  /// High priority
  static const Color priorityHigh = Color(0xFFEF4444);

  static const Color priorityHighBg = Color(0xFFFEE2E2);

  /// Medium priority
  static const Color priorityMedium = Color(0xFFFFB020);

  static const Color priorityMediumBg = Color(0xFFFFF3D6);

  /// Low priority
  static const Color priorityLow = Color(0xFF20C878);

  static const Color priorityLowBg = Color(0xFFDDF8EC);

  // ============================================================
  // Ticket Status
  // ============================================================

  /// New ticket
  static const Color statusNew = Color(0xFF1769FF);

  static const Color statusNewBg = Color(0xFFE5F0FF);

  /// Open ticket
  static const Color statusOpen = Color(0xFF29C5F6);

  static const Color statusOpenBg = Color(0xFFE1F8FD);

  /// In progress
  static const Color statusInProgress = Color(0xFFFFB020);

  static const Color statusInProgressBg = Color(0xFFFFF3D6);

  /// Resolved
  static const Color statusResolved = Color(0xFF20C878);

  static const Color statusResolvedBg = Color(0xFFDDF8EC);

  /// Closed
  static const Color statusClosed = Color(0xFF64748B);

  static const Color statusClosedBg = Color(0xFFF1F5F9);

  // ============================================================
  // Common UI
  // ============================================================

  static const Color transparent = Colors.transparent;

  static const Color white = Colors.white;

  static const Color black = Colors.black;

  /// Soft shadow
  static const Color shadow = Color(0x14000000);
}