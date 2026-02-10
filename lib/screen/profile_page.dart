import 'package:flutter/material.dart';
import 'package:lhc_front/constant/app_colors.dart';
import 'package:lhc_front/screen/edit_user.dart';
import 'package:lhc_front/screen/programme_page.dart';
import 'package:lhc_front/utils/image_helper.dart';
import '../models/User.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});

  final User user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _currentUser; // Variable locale pour gérer l'état

  @override
  void initState() {
    super.initState();
    _currentUser =
        widget.user; // Initialiser avec l'utilisateur passé en paramètre
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profil',
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
          onPressed: () => Navigator.pop(
            context,
            _currentUser,
          ), // Retourner l'utilisateur mis à jour
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUserScreen(user: _currentUser),
                ),
              );

              // Si un utilisateur mis à jour est retourné, mettre à jour l'affichage
              if (result != null && result is User) {
                setState(() {
                  _currentUser = result; // Remplacer complètement l'utilisateur
                });
              }
            },
            icon: const Icon(Icons.edit, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image de profil en grand
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(color: AppColors.background),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.background,
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(75),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(75),
                          child: ImageHelper.profileImage(_currentUser.imageUri),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Prénom et Nom
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Text(
                      _currentUser.fullName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    _buildRoleBadge(_currentUser.role),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Informations supplémentaires
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: _currentUser.email,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: 'Téléphone',
                      value: _currentUser.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.cake,
                      label: 'Âge',
                      value: '${_currentUser.age} ans',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.monitor_weight,
                      label: 'Poids',
                      value: '${_currentUser.weight} kg',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              if (_currentUser.role.toUpperCase() != 'ATHLETE_CO')
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [_buildOptionRow(label: 'Programmes')],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionRow({required String label}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgrammePage(
              user: _currentUser,
              onProgramsUpdated: (updatedPrograms) {
                // Mettre à jour l'utilisateur local avec les nouveaux programmes
                setState(() {
                  _currentUser = _currentUser.copyWith(
                    progUri: updatedPrograms,
                  );
                });
              },
            ),
          ),
        );
      },
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color badgeColor;
    String displayText = role;

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
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
