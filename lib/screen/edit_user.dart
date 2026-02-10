import 'package:flutter/material.dart';
import 'package:lhc_front/models/User.dart';
import 'package:lhc_front/services/user.dart';
import 'package:lhc_front/services/supabase_storage.dart';
import 'package:lhc_front/utils/image_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/app_colors.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key, required this.user});

  final User user;

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseStorageService _storageService = SupabaseStorageService();
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _ageController;
  late final TextEditingController _phoneController;
  late final TextEditingController _weightController;
  late final TextEditingController _emailController;

  bool _isLoading = false;
  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les données de l'utilisateur
    _nameController = TextEditingController(text: widget.user.name);
    _surnameController = TextEditingController(text: widget.user.surname);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _phoneController = TextEditingController(text: widget.user.phone);
    _weightController = TextEditingController(
      text: widget.user.weight.toString(),
    );
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      File imageFile = File(result.files.single.path!);

      setState(() {
        _newProfileImage = imageFile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Photo de profil sélectionnée. Elle sera mise à jour lors de l\'enregistrement.',
          ),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection de l\'image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveUserChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Comparer les données pour n'envoyer que les champs modifiés
      Map<String, dynamic> updatedData = {};

      // Vérifier chaque champ et n'ajouter que s'il a changé
      if (_nameController.text.trim() != widget.user.name) {
        updatedData['name'] = _nameController.text.trim();
      }
      if (_surnameController.text.trim() != widget.user.surname) {
        updatedData['surname'] = _surnameController.text.trim();
      }
      if (_emailController.text.trim() != widget.user.email) {
        updatedData['email'] = _emailController.text.trim();
      }
      if (_phoneController.text.trim() != widget.user.phone) {
        updatedData['phone'] = _phoneController.text.trim();
      }

      // Pour les champs numériques, comparer en toute sécurité
      final newAge = int.tryParse(_ageController.text) ?? widget.user.age;
      if (newAge != widget.user.age) {
        updatedData['age'] = newAge;
      }

      final newWeight =
          int.tryParse(_weightController.text) ?? widget.user.weight;
      if (newWeight != widget.user.weight) {
        updatedData['weight'] = newWeight;
      }

      // Envoyer les données utilisateur si elles ont changé
      if (updatedData.isNotEmpty) {
        print('Données modifiées à envoyer: $updatedData');

        final result = await UserService.update(widget.user.id, updatedData);

        if (result['success'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['data'][0]['message']),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Gérer l'image de profil séparément si elle a changé
      String? newImagePath;
      if (_newProfileImage != null) {
        newImagePath = await _updateProfileImage();
      }

      // Créer l'objet User mis à jour
      User updatedUser = widget.user.copyWith(
        name: updatedData['name'],
        surname: updatedData['surname'],
        email: updatedData['email'],
        phone: updatedData['phone'],
        age: updatedData['age'],
        weight: updatedData['weight'],
        imageUri: newImagePath, // Ajouter le nouveau chemin de l'image
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Modifications enregistrées avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, updatedUser);
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _updateProfileImage() async {
    try {
      // Récupérer le token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token d\'authentification non trouvé');
      }

      final result = await _storageService.updateProfileImage(
        widget.user.id,
        _newProfileImage!,
        token,
      );

      if (result.statusCode != 200 && result.statusCode != 201) {
        throw Exception(
          'Erreur lors de la mise à jour de l\'image: ${result.body}',
        );
      }

      // Parser la réponse pour obtenir le nouveau chemin de l'image
      final responseData = jsonDecode(result.body);
      print('Réponse API image: $responseData');

      if (responseData['success'] == true &&
          responseData['data'] is List &&
          responseData['data'].isNotEmpty) {
        // L'API retourne l'objet User complet dans message
        var message = responseData['data'][0]['message'];
        if (message is Map && message['imageUri'] != null) {
          return message['imageUri'] as String;
        }
      }

      print('Structure de réponse non reconnue pour l\'image');
      return null;
    } catch (e) {
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Modifier le profil',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec avatar
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withValues(alpha: 0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: _newProfileImage != null
                                ? Image.file(
                                    _newProfileImage!,
                                    fit: BoxFit.cover,
                                  )
                                : ImageHelper.profileImage(
                                    widget.user.imageUri,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.user.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildRoleBadge(widget.user.role),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Section Informations personnelles
              _buildSectionHeader('Informations personnelles', Icons.person),

              const SizedBox(height: 16),

              // Grid pour les champs
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 2.5,
                children: [
                  _buildCompactTextField(
                    controller: _nameController,
                    label: 'Nom',
                    hintText: 'Nom',
                    icon: Icons.person,
                  ),
                  _buildCompactTextField(
                    controller: _surnameController,
                    label: 'Prénom',
                    hintText: 'Prénom',
                    icon: Icons.person_outline,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildCompactTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'adresse@email.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              _buildCompactTextField(
                controller: _phoneController,
                label: 'Téléphone',
                hintText: '06 12 34 56 78',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),

              // Section Détails physiques
              _buildSectionHeader('Détails physiques', Icons.fitness_center),

              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 2.5,
                children: [
                  _buildCompactTextField(
                    controller: _ageController,
                    label: 'Âge',
                    hintText: '25',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                  _buildCompactTextField(
                    controller: _weightController,
                    label: 'Poids (kg)',
                    hintText: '70',
                    icon: Icons.monitor_weight,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Bouton de sauvegarde
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveUserChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.buttonSecondary,
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 8),
                            Text(
                              'Enregistrer les modifications',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          labelStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color badgeColor;

    switch (role) {
      case 'COACH':
        badgeColor = AppColors.coach;
        break;
      case 'ATHLETE_FULL':
        badgeColor = AppColors.athleteFull;
        break;
      case 'ATHLETE_PROG':
        badgeColor = AppColors.athleteProg;
        break;
      case 'ATHLETE_CO':
        badgeColor = AppColors.athleteCo;
        break;
      default:
        badgeColor = AppColors.black;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
