import 'package:flutter/material.dart';
import '../../../../constant/app_colors.dart';
import '../../../user/presentation/screens/edit_user.dart';
import '../../../user/presentation/screens/programme_page.dart';
import '../../../../utils/image_helper.dart';
import '../../../../models/User.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/role_badge.dart';

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
                print(
                  'ProfilePage: Mise à jour utilisateur avec nouvelles stats: ${result.stat}',
                );
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
                height: 200,
                decoration: BoxDecoration(color: AppColors.background),
                child: Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
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
              ),

              // Prénom et Nom
              AppCard(
                child: Padding(
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
                      RoleBadge(role: _currentUser.role),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              if (_currentUser.role.toUpperCase() != 'ATHLETE_CO')
                // Stats de force
                AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(children: [_buildStatsRow()]),
                ),
              const SizedBox(height: 30),

              // Informations supplémentaires
              AppCard(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.all(20.0),
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
                AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(20.0),
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

  Widget _buildStatsRow() {
    // Extraire les stats depuis l'utilisateur
    final squat = _getStatValue('squat');
    final bench = _getStatValue('bench');
    final deadlift = _getStatValue('deadlift');

    return Row(
      children: [
        // Squat
        Expanded(
          child: Column(
            children: [
              Text(
                'Squat',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                squat,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Séparateur vertical
        Container(
          width: 1,
          height: 60,
          color: AppColors.textSecondary.withValues(alpha: 0.3),
        ),

        // Bench Press
        Expanded(
          child: Column(
            children: [
              Text(
                'Bench',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                bench,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Séparateur vertical
        Container(
          width: 1,
          height: 60,
          color: AppColors.textSecondary.withValues(alpha: 0.3),
        ),

        // Deadlift
        Expanded(
          child: Column(
            children: [
              Text(
                'Deadlift',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                deadlift,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatValue(String exerciseName) {
    // Vérifier si l'utilisateur a des stats
    if (_currentUser.stat.isEmpty) {
      return '0 kg';
    }

    // Les stats sont dans le premier élément du tableau avec des propriétés directes
    final stats = _currentUser.stat.first;

    // Vérifier s'il y a un message imbriqué (cas des stats mises à jour)
    final messageStats = stats['message'] as Map<String, dynamic>?;
    final finalStats = messageStats ?? stats;

    switch (exerciseName.toLowerCase()) {
      case 'squat':
        return '${finalStats['squat'] ?? 0} kg';
      case 'bench':
        return '${finalStats['bench'] ?? 0} kg';
      case 'deadlift':
        return '${finalStats['deadlift'] ?? 0} kg';
      default:
        return '0 kg';
    }
  }
}
