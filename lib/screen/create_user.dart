import 'package:flutter/material.dart';
import 'package:lhc_front/services/user.dart';
import '../constant/app_colors.dart';

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
        backgroundColor: AppColors.background,
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
            _buildTextField(
              controller: _nameController,
              label: 'Nom',
              hintText: 'Entrez le nom',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Champ Prénom
            _buildTextField(
              controller: _surnameController,
              label: 'Prénom',
              hintText: 'Entrez le prénom',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer un prénom';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Champ Âge
            _buildTextField(
              controller: _ageController,
              label: 'Âge',
              hintText: 'Entrez l\'âge',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer un âge';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Champ Téléphone
            _buildTextField(
              controller: _phoneController,
              label: 'Téléphone',
              hintText: 'Entrez le numéro de téléphone',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer un numéro de téléphone';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Champ Poids
            _buildTextField(
              controller: _weightController,
              label: 'Poids (kg)',
              hintText: 'Entrez le poids',
              icon: Icons.monitor_weight,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer un poids';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Champ Email
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hintText: 'Entrez l\'adresse email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer un email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Champ Mot de passe temporaire
            _buildTextField(
              controller: _tempPasswordController,
              label: 'Mot de passe temporaire',
              hintText: 'Entrez un mot de passe temporaire',
              icon: Icons.lock,
              obscureText: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer un mot de passe temporaire';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Champ Rôle
            _buildRoleDropdown(),

            const SizedBox(height: 30),

            // Bouton de création
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: AppColors.buttonSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.buttonSecondary,
                      )
                    : const Text(
                        'Créer l\'utilisateur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
      ),
      validator: validator,
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
