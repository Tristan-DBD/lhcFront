import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StatDisplay extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const StatDisplay({
    required this.label,
    required this.value,
    this.showDivider = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.current.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.current.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            width: 1,
            height: 60,
            color: AppColors.current.textSecondary.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}
