import 'package:flutter/material.dart';
import 'package:lhc_front/core/theme/app_theme.dart';
import 'package:lhc_front/features/user/presentation/controllers/user_controller.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/app_snackbar.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late final UserController _controller;

  // Controllers
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _weightController = TextEditingController();

  // Focus nodes pour la navigation entre champs
  final _nameFocusNode = FocusNode();
  final _surnameFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _weightFocusNode = FocusNode();

  String _selectedRole = 'ATHLETE_PROG';
  bool _isLoading = false;

  final List<String> _roles = ['ATHLETE_PROG', 'ATHLETE_CO', 'ATHLETE_FULL'];

  @override
  void initState() {
    super.initState();
    _controller = UserController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = {
        'name':
            _surnameController.text, // Le backend attend le Prénom dans 'name'
        'surname': _nameController
            .text, // Le backend attend le Nom dans 'surname'.trim(),
        'age': int.parse(_ageController.text),
        'phone': _phoneController.text.trim(),
        'weight': int.parse(_weightController.text),
        'role': _selectedRole,
      };

      final result = await _controller.createUser(userData);

      if (!result.success) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          final message = result.errorMessage ?? 'Erreur lors de la création';
          AppSnackBar.show(
            context,
            message: message,
            isError: true,
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          AppSnackBar.show(
            context,
            message: 'Utilisateur créé avec succès',
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Erreur lors de la création : $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Création d\'un utilisateur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _nameController,
              labelText: 'Nom',
              hintText: 'Entrez le nom',
              prefixIcon: Icons.person,
              focusNode: _nameFocusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_surnameFocusNode);
              },
              validator: (value) => Validators.name(value, 'nom'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _surnameController,
              labelText: 'Prénom',
              hintText: 'Entrez le prénom',
              prefixIcon: Icons.person_outline,
              focusNode: _surnameFocusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_ageFocusNode);
              },
              validator: (value) => Validators.name(value, 'prénom'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _ageController,
              labelText: 'Âge',
              hintText: 'Entrez l\'âge',
              prefixIcon: Icons.cake,
              keyboardType: TextInputType.number,
              focusNode: _ageFocusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_phoneFocusNode);
              },
              validator: Validators.age,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              labelText: 'Téléphone',
              hintText: 'Entrez le numéro de téléphone',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              focusNode: _phoneFocusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_weightFocusNode);
              },
              validator: Validators.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _weightController,
              labelText: 'Poids (kg)',
              hintText: 'Entrez le poids',
              prefixIcon: Icons.monitor_weight,
              keyboardType: TextInputType.number,
              focusNode: _weightFocusNode,
              textInputAction: TextInputAction.next,
              validator: Validators.weight,
            ),
            const SizedBox(height: 16),
            _buildRoleDropdown(),
            const SizedBox(height: 30),
            AppButton(
              text: 'Créer l\'utilisateur',
              isFullWidth: true,
              height: 50,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _createUser,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rôle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border,
            ),
            borderRadius: BorderRadius.circular(8.0),
            color: AppColors.inputBackground,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole,
              isExpanded: true,
              items: _roles.map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Row(
                    children: [
                      Icon(
                        _getRoleIcon(role),
                        color: _getRoleColor(role),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getRoleDisplayName(role),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  IconData _getRoleIcon(String role) {
    if (role == 'ATHLETE_FULL') return Icons.fitness_center;
    if (role == 'ATHLETE_PROG') return Icons.trending_up;
    if (role == 'ATHLETE_CO') return Icons.sports;
    return Icons.person;
  }

  Color _getRoleColor(String role) {
    if (role == 'ATHLETE_FULL') return AppColors.current.athleteFull;
    if (role == 'ATHLETE_PROG') return AppColors.current.athleteProg;
    if (role == 'ATHLETE_CO') return AppColors.current.athleteCo;
    return AppColors.current.textSecondary;
  }

  String _getRoleDisplayName(String role) {
    if (role == 'ATHLETE_FULL') return 'Athlète Programme + Collectif';
    if (role == 'ATHLETE_PROG') return 'Athlète Programme';
    if (role == 'ATHLETE_CO') return 'Athlète Collectif';
    return role;
  }
}
