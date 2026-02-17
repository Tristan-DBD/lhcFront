import 'package:flutter/material.dart';
import '../../../../services/user.dart';
import '../../../../constant/app_colors.dart';
import '../../../../widgets/app_text_field.dart';
import '../../../../widgets/app_button.dart';
import '../../../../utils/validators.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _weightController = TextEditingController();
  final _emailController = TextEditingController();
  final _tempPasswordController = TextEditingController();

  String _selectedRole = 'ATHLETE_PROG';
  bool _isLoading = false;

  final List<String> _roles = ['ATHLETE_PROG', 'ATHLETE_CO', 'ATHLETE_FULL'];

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _emailController.dispose();
    _tempPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = {
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'age': int.parse(_ageController.text),
        'phone': _phoneController.text.trim(),
        'weight': int.parse(_weightController.text),
        'email': _emailController.text.trim(),
        'password': _tempPasswordController.text.trim(),
        'role': _selectedRole,
      };

      final user = await UserService.create(userData);
      print('Utilisateur créé: $user');
      if (user['success'] == false) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(user['data'][0]['message']),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Utilisateur créé avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Erreur: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Création d\'un utilisateur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.secondary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champ Nom
            AppTextField(
              controller: _nameController,
              labelText: 'Nom',
              hintText: 'Entrez le nom',
              prefixIcon: Icons.person,
              validator: (value) => Validators.name(value, 'nom'),
            ),

            const SizedBox(height: 16),

            // Champ Prénom
            AppTextField(
              controller: _surnameController,
              labelText: 'Prénom',
              hintText: 'Entrez le prénom',
              prefixIcon: Icons.person_outline,
              validator: (value) => Validators.name(value, 'prénom'),
            ),

            const SizedBox(height: 16),

            // Champ Âge
            AppTextField(
              controller: _ageController,
              labelText: 'Âge',
              hintText: 'Entrez l\'âge',
              prefixIcon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: Validators.age,
            ),

            const SizedBox(height: 16),

            // Champ Téléphone
            AppTextField(
              controller: _phoneController,
              labelText: 'Téléphone',
              hintText: 'Entrez le numéro de téléphone',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
            ),

            const SizedBox(height: 16),

            // Champ Poids
            AppTextField(
              controller: _weightController,
              labelText: 'Poids (kg)',
              hintText: 'Entrez le poids',
              prefixIcon: Icons.monitor_weight,
              keyboardType: TextInputType.number,
              validator: Validators.weight,
            ),

            const SizedBox(height: 16),

            // Champ Email
            AppTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Entrez l\'adresse email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),

            const SizedBox(height: 16),

            // Champ Mot de passe temporaire
            AppTextField(
              controller: _tempPasswordController,
              labelText: 'Mot de passe temporaire',
              hintText: 'Entrez un mot de passe temporaire',
              prefixIcon: Icons.lock,
              obscureText: true,
              validator: Validators.password,
            ),

            const SizedBox(height: 16),

            // Champ Rôle
            _buildRoleDropdown(),

            const SizedBox(height: 30),

            // Bouton de création
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
        const Text(
          'Rôle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.inputBorder),
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
                          style: const TextStyle(
                            color: AppColors.textPrimary,
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
    switch (role) {
      case 'ATHLETE_FULL':
        return Icons.fitness_center;
      case 'ATHLETE_PROG':
        return Icons.trending_up;
      case 'ATHLETE_CO':
        return Icons.sports;
      default:
        return Icons.person;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ATHLETE_FULL':
        return AppColors.athleteFull;
      case 'ATHLETE_PROG':
        return AppColors.athleteProg;
      case 'ATHLETE_CO':
        return AppColors.athleteCo;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'ATHLETE_FULL':
        return 'Athlète Programme + Collectif';
      case 'ATHLETE_PROG':
        return 'Athlète Programme';
      case 'ATHLETE_CO':
        return 'Athlète Collectif';
      default:
        return role;
    }
  }
}
