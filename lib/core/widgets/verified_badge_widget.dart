import 'package:flutter/material.dart';

class VerifiedBadgeWidget extends StatelessWidget {
  final double size;
  final bool showLabel;
  final String label;

  const VerifiedBadgeWidget({
    super.key,
    this.size = 16,
    this.showLabel = false,
    this.label = 'Verified',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!showLabel) {
      return Icon(
        Icons.verified_rounded,
        size: size,
        color: const Color(0xFF2563EB),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3B82F6).withValues(alpha: 0.4) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: size,
            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
