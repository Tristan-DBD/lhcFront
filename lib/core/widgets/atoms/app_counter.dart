import 'package:flutter/material.dart';

class AppCounter extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int minValue;
  final Color? color;

  const AppCounter({
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
    this.minValue = 0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            onPressed: value > minValue ? onDecrement : null,
            context: context,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add,
            onPressed: onIncrement,
            context: context,
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required BuildContext context,
    bool isActive = false,
  }) {
    final activeColor = color ?? Theme.of(context).colorScheme.secondary;
    
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
      color: isActive ? activeColor : Theme.of(context).colorScheme.onSurfaceVariant,
      disabledColor: Theme.of(context).disabledColor.withValues(alpha: 0.3),
    );
  }
}
