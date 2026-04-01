import 'package:flutter/material.dart';
import 'app_snackbar.dart';

/// Service centralisé pour afficher des messages à l'utilisateur
class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  /// Affiche un message d'erreur
  static void showError(BuildContext context, String message) {
    AppSnackBar.show(context, message: message, isError: true);
  }

  /// Affiche un message de succès
  static void showSuccess(BuildContext context, String message) {
    AppSnackBar.show(context, message: message, isError: false);
  }

  /// Affiche un message d'information
  static void showInfo(BuildContext context, String message) {
    AppSnackBar.show(context, message: message, isError: false);
  }

  /// Affiche un message d'avertissement
  static void showWarning(BuildContext context, String message) {
    AppSnackBar.show(context, message: message, isError: true);
  }

  /// Affiche un message personnalisé
  static void showCustom(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    AppSnackBar.show(context, message: message, isError: isError);
  }

  /// Cache tous les snackbars actuellement affichés
  static void hideAll(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Affiche un dialogue de confirmation
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor:
                  confirmColor ?? Theme.of(context).colorScheme.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Affiche un dialogue d'information
  static void showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
