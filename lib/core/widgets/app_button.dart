import 'package:flutter/material.dart';

/// Widget réutilisable pour les boutons avec style cohérent
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final BorderRadius? borderRadius;
  final double? elevation;
  final TextStyle? textStyle;
  final Widget? child;
  final ButtonStyle? style;

  const AppButton({
    required this.text, super.key,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height = 45,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.borderRadius,
    this.elevation = 2,
    this.textStyle,
    this.child,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild =
        child ??
        Text(
          text,
          style:
              textStyle ??
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        );

    final buttonStyle =
        style ??
        ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor:
              foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
          disabledBackgroundColor:
              disabledBackgroundColor ??
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8.0),
          ),
          elevation: elevation,
          minimumSize: Size(
            isFullWidth ? double.infinity : (width ?? 0),
            height ?? 45,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );

    if (isFullWidth || width != null) {
      return SizedBox(
        width: isFullWidth ? double.infinity : width,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      foregroundColor ??
                          Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
              : buttonChild,
        ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
          : buttonChild,
    );
  }
}

/// Bouton texte pour les actions secondaires
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final TextStyle? textStyle;
  final bool isFullWidth;

  const AppTextButton({
    required this.text, super.key,
    this.onPressed,
    this.color,
    this.textStyle,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? Theme.of(context).colorScheme.primary,
        minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
      ),
      child: Text(text, style: textStyle ?? const TextStyle(fontSize: 12)),
    );
  }
}
