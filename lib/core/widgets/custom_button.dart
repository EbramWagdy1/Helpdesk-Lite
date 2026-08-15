import 'package:flutter/material.dart';
import 'package:helpdesk/core/utils/app_colors.dart';
import 'package:helpdesk/core/utils/app_text_style.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.borderRadius = 14,
    this.gradient,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.borderColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = backgroundColor == null && borderColor == null
        ? (gradient ?? AppColors.primaryGradient)
        : null;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        color: backgroundColor ?? (effectiveGradient == null ? AppColors.primary : null),
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1.5) : null,
        boxShadow: (backgroundColor == Colors.transparent || borderColor != null)
            ? null
            : [
                BoxShadow(
                  color: (backgroundColor ?? AppColors.primary).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: textColor ?? (borderColor != null ? AppColors.primary : AppColors.white),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
