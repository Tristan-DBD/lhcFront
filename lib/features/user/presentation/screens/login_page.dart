import 'package:flutter/material.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/message_service.dart';
import '../../../../core/utils/validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  // Focus nodes pour la navigation entre champs
  final _loginFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  final _confirmPasswordFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _loginFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Méthode pour gérer la connexion
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final login = await AuthService.login(
        _loginController.text,
        _passwordController.text,
      );

      if (login['success'] == true) {
        final token = login['data'][0]['message'];
        await StorageService.saveToken(token);

        // Si le mot de passe est le mot de passe par défaut, forcer le changement
        if (_passwordController.text == '123456') {
          setState(() => _isLoading = false);
          if (mounted) {
            _showPasswordChangeDialog();
          }
        } else {
          if (mounted) {
            NavigationHelper.initNavigation(context);
          }
        } 
      } else {
        if (mounted) {
          MessageService.showError(context, login['data'][0]['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError(context, 'Erreur de connexion: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPasswordChangeDialog() {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    bool isChanging = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Changer votre mot de passe'),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'C\'est votre première connexion. Veuillez sécuriser votre compte avec un nouveau mot de passe (min. 6 caractères).',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: newPasswordController,
                  labelText: 'Nouveau mot de passe',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  onSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                  },
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Minimum 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: confirmPasswordController,
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: Icons.lock_reset,
                  obscureText: true,
                  focusNode: _confirmPasswordFocusNode,
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            AppButton(
              text: 'Mettre à jour',
              isLoading: isChanging,
              onPressed: () async {
                if (dialogFormKey.currentState!.validate()) {
                  setDialogState(() => isChanging = true);
                  try {
                    final response = await AuthService.changePassword(
                      newPasswordController.text,
                    );
                    if (response['success'] == true) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        MessageService.showSuccess(
                          context,
                          'Mot de passe mis à jour !',
                        );
                        NavigationHelper.initNavigation(context);
                      }
                    } else {
                      if (context.mounted) {
                        MessageService.showError(
                          context,
                          response['data'][0]['message'],
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      MessageService.showError(
                        context,
                        'Erreur lors du changement: $e',
                      );
                    }
                  } finally {
                    setDialogState(() => isChanging = false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final logoSize = ResponsiveHelper.isMobile(context) ? 100.0 : 120.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: AppCard(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: screenHeight * 0.1,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.getCardMaxWidth(context),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 5),
                    // Logo et titre
                    Column(
                      children: [
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/logoLhc.png',
                            width: logoSize,
                            height: logoSize,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'LHC Coaching',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Connectez-vous à votre compte',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Champ Login
                    AppTextField(
                      controller: _loginController,
                      labelText: 'Login',
                      hintText: 'Entrez votre login',
                      prefixIcon: Icons.person,
                      focusNode: _loginFocusNode,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        // Passer au champ mot de passe quand on appuie sur Entrée
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                      validator: (value) => Validators.required(value, 'login'),
                    ),

                    const SizedBox(height: 14),

                    // Champ Mot de passe
                    AppTextField(
                      controller: _passwordController,
                      labelText: 'Mot de passe',
                      hintText: 'Entrez votre mot de passe',
                      prefixIcon: Icons.lock,
                      obscureText: true,
                      focusNode: _passwordFocusNode,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        // Soumettre le formulaire quand on appuie sur Entrée
                        if (_formKey.currentState!.validate()) {
                          // Appeler la fonction de connexion
                          _handleLogin();
                        }
                      },
                      validator: (value) =>
                          Validators.required(value, 'mot de passe'),
                    ),

                    const SizedBox(height: 50),

                    // Bouton Se connecter
                    AppButton(
                      text: 'Se connecter',
                      isFullWidth: true,
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
