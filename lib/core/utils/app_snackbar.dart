import 'package:flutter/material.dart';

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? colorScheme.onError : colorScheme.onSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isError ? colorScheme.onError : colorScheme.onSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? colorScheme.error : colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
