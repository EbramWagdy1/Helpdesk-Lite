import 'package:flutter/material.dart';

/// Curated Dark Mode color palette for HelpDesk Lite.
/// Designed for high visual contrast, sleek slate backgrounds,
/// and harmonious accents matching the brand.
class DarkAppColors {
  // ============================================================
  // Brand Colors (Optimized for Dark Surfaces)
  // ============================================================

  /// Main brand blue - slightly brighter for dark backgrounds
  static const Color primary = Color(0xFF3B82F6);

  /// Vibrant cyan highlight
  static const Color primaryLight = Color(0xFF38BDF8);

  /// Deep navy container
  static const Color primaryDark = Color(0xFF1E40AF);

  /// Soft sky blue accent
  static const Color primaryAccent = Color(0xFF60A5FA);

  // ============================================================
  // Secondary / Accent Colors
  // ============================================================

  /// Cyan accent
  static const Color secondary = Color(0xFF06B6D4);

  /// Emerald green for success / resolved status
  static const Color accent = Color(0xFF10B981);

  /// Amber / Gold notification accent
  static const Color notification = Color(0xFFFBBF24);

  // ============================================================
  // Gradients
  // ============================================================

  /// Dark brand gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF1E3A8A),
      Color(0xFF2563EB),
      Color(0xFF0284C7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient for dark elevated cards
  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft dark background gradient
  static const LinearGradient softGradient = LinearGradient(
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // Background & Surface Colors (Slate Palette)
  // ============================================================

  /// Deep slate canvas background
  static const Color background = Color(0xFF0F172A);

  /// Elevated card / modal surface
  static const Color surface = Color(0xFF1E293B);

  /// Slightly elevated container / field fill
  static const Color surfaceVariant = Color(0xFF334155);

  /// Higher elevation surface (dropdowns, dialogs)
  static const Color surfaceElevated = Color(0xFF273549);

  /// Card background
  static const Color cardBackground = Color(0xFF1E293B);

  // ============================================================
  // Text Colors
  // ============================================================

  /// Main text - crisp near-white
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// Secondary text - soft slate
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Muted / disabled text
  static const Color textMuted = Color(0xFF64748B);

  /// Text on dark/primary buttons
  static const Color textLight = Color(0xFFFFFFFF);

  // ============================================================
  // Border & Divider
  // ============================================================

  static const Color border = Color(0xFF334155);

  static const Color borderFocused = Color(0xFF38BDF8);

  static const Color divider = Color(0xFF1E293B);

  // ============================================================
  // Status Colors (Dark Background Tints)
  // ============================================================

  /// Success
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF064E3B);
  static const Color successText = Color(0xFF6EE7B7);

  /// Warning
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFF78350F);
  static const Color warningText = Color(0xFFFDE68A);

  /// Error
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFF7F1D1D);
  static const Color errorText = Color(0xFFFCA5A5);

  /// Info
  static const Color info = Color(0xFF38BDF8);
  static const Color infoLight = Color(0xFF0C4A6E);
  static const Color infoText = Color(0xFFBAE6FD);

  // ============================================================
  // Ticket Priority
  // ============================================================

  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityHighBg = Color(0xFF450A0A);

  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityMediumBg = Color(0xFF451A03);

  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityLowBg = Color(0xFF022C22);

  // ============================================================
  // Ticket Status
  // ============================================================

  static const Color statusNew = Color(0xFF3B82F6);
  static const Color statusNewBg = Color(0xFF172554);

  static const Color statusOpen = Color(0xFF06B6D4);
  static const Color statusOpenBg = Color(0xFF083344);

  static const Color statusInProgress = Color(0xFFF59E0B);
  static const Color statusInProgressBg = Color(0xFF451A03);

  static const Color statusResolved = Color(0xFF10B981);
  static const Color statusResolvedBg = Color(0xFF022C22);

  static const Color statusClosed = Color(0xFF94A3B8);
  static const Color statusClosedBg = Color(0xFF1E293B);

  // ============================================================
  // Common UI
  // ============================================================

  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color shadow = Color(0x40000000);
}
