import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../../data/services/stat_service.dart';
import '../../data/services/user_service.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/storage/supabase_storage.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../../core/utils/message_service.dart';
import '../../../../core/widgets/atoms/section_header.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({required this.user, super.key});

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
  late final TextEditingController _squatController;
  late final TextEditingController _benchController;
  late final TextEditingController _deadliftController;

  // Focus nodes pour la navigation entre champs
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _surnameFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();
  final _weightFocusNode = FocusNode();
  final _squatFocusNode = FocusNode();
  final _benchFocusNode = FocusNode();
  final _deadliftFocusNode = FocusNode();

  bool _isLoading = false;
  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les données de l'utilisateur
    _nameController = TextEditingController(text: widget.user.surname);
    _surnameController = TextEditingController(text: widget.user.name);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _phoneController = TextEditingController(text: widget.user.phone);
    _weightController = TextEditingController(
      text: widget.user.weight.toString(),
    );
    _emailController = TextEditingController(text: widget.user.email);
    if (widget.user.stat.isEmpty) {
      _squatController = TextEditingController(text: '0');
      _benchController = TextEditingController(text: '0');
      _deadliftController = TextEditingController(text: '0');
    } else {
      final stats = widget.user.stat[0];
      // Vérifier s'il y a un message imbriqué (cas des stats mises à jour)
      final messageStats = stats['message'] as Map<String, dynamic>?;
      final finalStats = messageStats ?? stats;

      _squatController = TextEditingController(
        text: finalStats['squat'].toString(),
      );
      _benchController = TextEditingController(
        text: finalStats['bench'].toString(),
      );
      _deadliftController = TextEditingController(
        text: finalStats['deadlift'].toString(),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _emailController.dispose();
    _squatController.dispose();
    _benchController.dispose();
    _deadliftController.dispose();

    // Nettoyer les focus nodes
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _nameFocusNode.dispose();
    _surnameFocusNode.dispose();
    _ageFocusNode.dispose();
    _weightFocusNode.dispose();
    _squatFocusNode.dispose();
    _benchFocusNode.dispose();
    _deadliftFocusNode.dispose();

    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final File imageFile = File(result.files.single.path!);

      setState(() {
        _newProfileImage = imageFile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Photo de profil sélectionnée. Elle sera mise à jour lors de l\'enregistrement.',
          ),
          backgroundColor: AppColors.current.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection de l\'image: $e'),
          backgroundColor: AppColors.current.error,
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
      final Map<String, dynamic> updatedData = {};
      final Map<String, dynamic> updatedStatsData = {};

      // Vérifier chaque champ et n'ajouter que s'il a changé
      if (_surnameController.text.trim() != widget.user.name) {
        updatedData['name'] = _surnameController.text.trim();
      }
      if (_nameController.text.trim() != widget.user.surname) {
        updatedData['surname'] = _nameController.text.trim();
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

      // pour les stats
      if (widget.user.stat.isNotEmpty) {
        final stats = widget.user.stat[0];
        // Vérifier s'il y a un message imbriqué (cas des stats mises à jour)
        final messageStats = stats['message'] as Map<String, dynamic>?;
        final finalStats = messageStats ?? stats;

        final currentSquat =
            double.tryParse(_squatController.text.replaceAll(',', '.')) ?? 0.0;
        final currentBench =
            double.tryParse(_benchController.text.replaceAll(',', '.')) ?? 0.0;
        final currentDeadlift =
            double.tryParse(_deadliftController.text.replaceAll(',', '.')) ??
            0.0;

        final apiSquat = (finalStats['squat'] as num).toDouble();
        final apiBench = (finalStats['bench'] as num).toDouble();
        final apiDeadlift = (finalStats['deadlift'] as num).toDouble();

        if (currentSquat != apiSquat) {
          updatedStatsData['squat'] = currentSquat;
        }
        if (currentBench != apiBench) {
          updatedStatsData['bench'] = currentBench;
        }
        if (currentDeadlift != apiDeadlift) {
          updatedStatsData['deadlift'] = currentDeadlift;
        }
      } else {
        // Si pas de stats existantes, considérer tous les champs comme modifiés
        updatedStatsData['squat'] =
            double.tryParse(_squatController.text.replaceAll(',', '.')) ?? 0.0;
        updatedStatsData['bench'] =
            double.tryParse(_benchController.text.replaceAll(',', '.')) ?? 0.0;
        updatedStatsData['deadlift'] =
            double.tryParse(_deadliftController.text.replaceAll(',', '.')) ??
            0.0;
      }

      // Envoyer les données utilisateur si elles ont changé
      if (updatedData.isNotEmpty) {
        final response = await UserService.update(widget.user.id, updatedData);

        if (!response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.errorMessage ?? 'Erreur lors de la mise à jour',
              ),
              backgroundColor: AppColors.current.error,
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

      // Mettre à jour les stats si elles ont été modifiées
      User updatedUser = widget.user;
      if (updatedStatsData.isNotEmpty) {
        final Map<String, dynamic>? updatedStatsResult = await _updateStats();
        if (updatedStatsResult == null) return;
        final updatedStats = updatedStatsResult;

        if (widget.user.stat.isEmpty) {
          // Création de nouvelles stats
          if (updatedStats['data'] is List && updatedStats['data'].isNotEmpty) {
            updatedUser = widget.user.copyWith(
              name: updatedData['name'],
              surname: updatedData['surname'],
              email: updatedData['email'],
              phone: updatedData['phone'],
              age: updatedData['age'],
              weight: updatedData['weight'],
              imageUri: newImagePath,
              stat: [updatedStats['data'][0]],
            );
          } else {
            updatedUser = widget.user.copyWith(
              name: updatedData['name'],
              surname: updatedData['surname'],
              email: updatedData['email'],
              phone: updatedData['phone'],
              age: updatedData['age'],
              weight: updatedData['weight'],
              imageUri: newImagePath,
            );
          }
        } else {
          // Mise à jour des stats existantes
          final List<Map<String, dynamic>> newStats = List.from(
            widget.user.stat,
          );
          if (updatedStats['data'] is List && updatedStats['data'].isNotEmpty) {
            newStats[0] = {...newStats[0], ...updatedStats['data'][0]};
            updatedUser = widget.user.copyWith(
              name: updatedData['name'],
              surname: updatedData['surname'],
              email: updatedData['email'],
              phone: updatedData['phone'],
              age: updatedData['age'],
              weight: updatedData['weight'],
              imageUri: newImagePath,
              stat: newStats,
            );
          } else {
            updatedUser = widget.user.copyWith(
              name: updatedData['name'],
              surname: updatedData['surname'],
              email: updatedData['email'],
              phone: updatedData['phone'],
              age: updatedData['age'],
              weight: updatedData['weight'],
              imageUri: newImagePath,
            );
          }
        }
      } else {
        // Pas de modification de stats, créer l'utilisateur avec les données de base uniquement
        updatedUser = widget.user.copyWith(
          name: updatedData['name'] ?? widget.user.name,
          surname: updatedData['surname'] ?? widget.user.surname,
          email: updatedData['email'] ?? widget.user.email,
          phone: updatedData['phone'] ?? widget.user.phone,
          age: updatedData['age'] ?? widget.user.age,
          weight: updatedData['weight'] ?? widget.user.weight,
          imageUri: newImagePath ?? widget.user.imageUri,
        );
      }

      MessageService.showSuccess(
        context,
        'Modifications enregistrées avec succès',
      );
      if (mounted) {
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError(context, 'Erreur lors de la sauvegarde: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

      if (responseData['success'] == true &&
          responseData['data'] is List &&
          responseData['data'].isNotEmpty) {
        // L'API retourne l'objet User complet dans message
        final message = responseData['data'][0]['message'];
        if (message is Map && message['imageUri'] != null) {
          return message['imageUri'] as String;
        }
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _updateStats() async {
    try {
      ApiResponse<Map<String, dynamic>> result;

      if (widget.user.stat.isEmpty) {
        result = await StatService.create({
          'userId': widget.user.id,
          'squat':
              double.tryParse(_squatController.text.replaceAll(',', '.')) ??
              0.0,
          'bench':
              double.tryParse(_benchController.text.replaceAll(',', '.')) ??
              0.0,
          'deadlift':
              double.tryParse(_deadliftController.text.replaceAll(',', '.')) ??
              0.0,
        });
      } else {
        result = await StatService.update({
          'userId': widget.user.id,
          'squat':
              double.tryParse(_squatController.text.replaceAll(',', '.')) ??
              0.0,
          'bench':
              double.tryParse(_benchController.text.replaceAll(',', '.')) ??
              0.0,
          'deadlift':
              double.tryParse(_deadliftController.text.replaceAll(',', '.')) ??
              0.0,
        });
      }

      if (!result.success) {
        throw Exception(
          result.errorMessage ?? 'Erreur lors de la mise à jour des stats',
        );
      }

      // Pour la compatibilité avec le reste de _saveUserChanges, on retourne formaté
      return {
        'success': true,
        'data': [result.data],
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Modifier le profil',
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
                            color: AppColors.current.secondary,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.current.shadow.withValues(
                                  alpha: 0.1,
                                ),
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
                                color: AppColors.current.primary,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: AppColors.current.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: AppColors.current.white,
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.current.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RoleBadge(role: widget.user.role),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              AppTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'adresse@email.com',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                focusNode: _emailFocusNode,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_phoneFocusNode);
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: _phoneController,
                labelText: 'Téléphone',
                hintText: '06 12 34 56 78',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                focusNode: _phoneFocusNode,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_nameFocusNode);
                },
              ),

              const SizedBox(height: 20),

              const SectionHeader(
                title: 'Informations personnelles',
                icon: Icons.person,
              ),

              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(
                  context,
                  mobile: 1,
                  tablet: 2,
                  desktop: 2,
                ),
                crossAxisSpacing: 2,
                mainAxisSpacing: 8,
                childAspectRatio: ResponsiveHelper.isMobile(context)
                    ? 5.5
                    : 6.0,
                children: [
                  AppTextField(
                    controller: _nameController,
                    labelText: 'Nom',
                    hintText: 'Nom',
                    prefixIcon: Icons.person,
                    focusNode: _nameFocusNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_surnameFocusNode);
                    },
                  ),
                  AppTextField(
                    controller: _surnameController,
                    labelText: 'Prénom',
                    hintText: 'Prénom',
                    prefixIcon: Icons.person_outline,
                    focusNode: _surnameFocusNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_ageFocusNode);
                    },
                  ),
                ],
              ),

              const SectionHeader(
                title: 'Détails physiques',
                icon: Icons.fitness_center,
              ),

              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(
                  context,
                  mobile: 1,
                  tablet: 2,
                  desktop: 2,
                ),
                crossAxisSpacing: 15,
                mainAxisSpacing: 8,
                childAspectRatio: ResponsiveHelper.isMobile(context)
                    ? 5.5
                    : 6.0,
                children: [
                  AppTextField(
                    controller: _ageController,
                    labelText: 'Âge',
                    hintText: '25',
                    prefixIcon: Icons.cake,
                    keyboardType: TextInputType.number,
                    focusNode: _ageFocusNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_weightFocusNode);
                    },
                  ),
                  AppTextField(
                    controller: _weightController,
                    labelText: 'Poids (kg)',
                    hintText: '70',
                    prefixIcon: Icons.fitness_center,
                    keyboardType: TextInputType.number,
                    focusNode: _weightFocusNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_squatFocusNode);
                    },
                  ),
                ],
              ),

              const SectionHeader(title: 'Stats', icon: Icons.fitness_center),

              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(
                  context,
                  mobile: 1,
                  tablet: 2,
                  desktop: 2,
                ),
                crossAxisSpacing: 15,
                mainAxisSpacing: 8,
                childAspectRatio: ResponsiveHelper.isMobile(context)
                    ? 5.5
                    : 6.0,
                children: [
                  AppTextField(
                    controller: _squatController,
                    labelText: 'Squat',
                    hintText: '25',
                    prefixIcon: Icons.fitness_center,
                    keyboardType: TextInputType.number,
                    focusNode: _squatFocusNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_benchFocusNode);
                    },
                  ),
                  AppTextField(
                    controller: _benchController,
                    labelText: 'Bench Press',
                    hintText: '25',
                    prefixIcon: Icons.fitness_center,
                    keyboardType: TextInputType.number,
                    focusNode: _benchFocusNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_deadliftFocusNode);
                    },
                  ),
                  AppTextField(
                    controller: _deadliftController,
                    labelText: 'Deadlift',
                    hintText: '70',
                    prefixIcon: Icons.fitness_center,
                    keyboardType: TextInputType.number,
                    focusNode: _deadliftFocusNode,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      _saveUserChanges();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              AppButton(
                text: 'Enregistrer les modifications',
                isFullWidth: true,
                height: 50,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _saveUserChanges,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
