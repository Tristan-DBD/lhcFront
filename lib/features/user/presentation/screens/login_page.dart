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
    setState(() {
      _isLoading = true;
    });

    try {
      final login = await AuthService.login(
        _loginController.text,
        _passwordController.text,
      );

      if (login['success'] == true) {
        await StorageService.saveToken(login['data'][0]['message']);
        NavigationHelper.initNavigation(context);
      } else {
        MessageService.showError(context, login['data'][0]['message']);
      }
    } catch (e) {
      MessageService.showError(context, 'Erreur de connexion: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final logoSize = ResponsiveHelper.isMobile(context) ? 100.0 : 120.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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

                    const SizedBox(height: 12),

                    // Mot de passe oublié
                    Row(
                      children: [
                        const Spacer(),
                        const Spacer(),
                        AppTextButton(
                          text: 'Mot de passe oublié?',
                          onPressed: () {
                            // Action mot de passe oublié
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

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
