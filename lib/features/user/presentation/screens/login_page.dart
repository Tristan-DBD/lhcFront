import 'package:flutter/material.dart';
import '../../../../services/auth.dart';
import '../../../../services/storage.dart';
import '../../../../constant/app_colors.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/app_text_field.dart';
import '../../../../widgets/app_button.dart';
import '../../../../utils/message_service.dart';
import '../../../../utils/validators.dart';
import '../../../shared/presentation/screens/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir les dimensions de l'écran
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: AppCard(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.1,
              vertical: screenHeight * 0.15,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
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
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/logoLhc.png',
                            width: 120,
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'LHC Coaching',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Connectez-vous à votre compte',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            final login = await AuthService.login(
                              _loginController.text,
                              _passwordController.text,
                            );

                            if (login['success'] == true) {
                              await StorageService.saveToken(
                                login['data'][0]['message'],
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            } else {
                              MessageService.showError(
                                context,
                                login['data'][0]['message'],
                              );
                            }
                          } catch (e) {
                            print('Login error: $e');
                            MessageService.showError(
                              context,
                              'Erreur de connexion: $e',
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
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
