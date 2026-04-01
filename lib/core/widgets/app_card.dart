import 'package:flutter/material.dart';

/// Widget réutilisable pour les cartes avec style cohérent et effet Premium
class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const AppCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding ?? const EdgeInsets.all(20.0),
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16.0),
        boxShadow: widget.boxShadow ??
            [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(_isPressed ? 0.05 : 0.08),
                blurRadius: _isPressed ? 5 : 12,
                offset: Offset(0, _isPressed ? 2 : 6),
              ),
            ],
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: card,
        ),
      );
    }

    return card;
  }
}

