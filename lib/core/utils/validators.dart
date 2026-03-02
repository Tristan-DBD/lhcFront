/// Validateurs réutilisables pour les formulaires
class Validators {
  /// Valide qu'un champ n'est pas vide
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'Veuillez entrer votre $fieldName'
          : 'Ce champ est obligatoire';
    }
    return null;
  }

  /// Valide un email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Veuillez entrer un email valide';
    }

    return null;
  }

  /// Valide un mot de passe
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }

    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    return null;
  }

  /// Valide un numéro de téléphone
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }

    final phoneRegex = RegExp(r'^[0-9+\s()-]+$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }

    if (value.trim().length < 10) {
      return 'Le numéro de téléphone doit contenir au moins 10 chiffres';
    }

    return null;
  }

  /// Valide un nom ou prénom
  static String? name(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      final field = fieldName ?? 'nom';
      return 'Veuillez entrer votre $field';
    }

    if (value.trim().length < 2) {
      final field = fieldName ?? 'nom';
      return 'Le $field doit contenir au moins 2 caractères';
    }

    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s-]+$');

    if (!nameRegex.hasMatch(value.trim())) {
      final field = fieldName ?? 'nom';
      return 'Le $field ne doit contenir que des lettres';
    }

    return null;
  }

  /// Valide un âge
  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre âge';
    }

    final ageValue = int.tryParse(value.trim());

    if (ageValue == null) {
      return 'Veuillez entrer un âge valide';
    }

    if (ageValue < 1 || ageValue > 120) {
      return 'L\'âge doit être compris entre 1 et 120 ans';
    }

    return null;
  }

  /// Valide un poids
  static String? weight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre poids';
    }

    final weightValue = double.tryParse(value.trim().replaceFirst(',', '.'));

    if (weightValue == null) {
      return 'Veuillez entrer un poids valide';
    }

    if (weightValue < 20 || weightValue > 300) {
      return 'Le poids doit être compris entre 20 et 300 kg';
    }

    return null;
  }

  /// Valide la confirmation de mot de passe
  static String? passwordConfirmation(String? value, String? password) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  /// Valide une longueur minimale
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'Veuillez entrer votre $fieldName'
          : 'Ce champ est obligatoire';
    }

    if (value.trim().length < minLength) {
      final field = fieldName ?? 'Ce champ';
      return 'Le $field doit contenir au moins $minLength caractères';
    }

    return null;
  }

  /// Valide une longueur maximale
  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.trim().length > maxLength) {
      final field = fieldName ?? 'Ce champ';
      return 'Le $field ne doit pas dépasser $maxLength caractères';
    }

    return null;
  }

  /// Combine plusieurs validateurs
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
