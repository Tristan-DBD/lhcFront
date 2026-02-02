import 'package:flutter/material.dart';
import '../constant/app_colors.dart';

class ListUserPage extends StatefulWidget {
  const ListUserPage({super.key});

  @override
  State<ListUserPage> createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage> {
  // Liste des utilisateurs avec leurs informations
  final List<Map<String, String>> users = [
    {'name': 'Jean Dupont', 'role': 'Membre', 'email': 'jean.dupont@email.com'},
    {
      'name': 'Marie Martin',
      'role': 'Coach',
      'email': 'marie.martin@email.com',
    },
    {
      'name': 'Pierre Bernard',
      'role': 'Membre',
      'email': 'pierre.bernard@email.com',
    },
    {
      'name': 'Sophie Petit',
      'role': 'Membre',
      'email': 'sophie.petit@email.com',
    },
    {
      'name': 'Lucas Dubois',
      'role': 'Coach',
      'email': 'lucas.dubois@email.com',
    },
    {'name': 'Emma Leroy', 'role': 'Membre', 'email': 'emma.leroy@email.com'},
    {
      'name': 'Nicolas Moreau',
      'role': 'Membre',
      'email': 'nicolas.moreau@email.com',
    },
    {
      'name': 'Camille Laurent',
      'role': 'Coach',
      'email': 'camille.laurent@email.com',
    },
    {
      'name': 'Antoine Simon',
      'role': 'Membre',
      'email': 'antoine.simon@email.com',
    },
    {'name': 'Léa Garcia', 'role': 'Membre', 'email': 'lea.garcia@email.com'},
    {
      'name': 'Thomas Robert',
      'role': 'Membre',
      'email': 'thomas.robert@email.com',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Liste des utilisateurs',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grille des utilisateurs
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserCard(
                      name: user['name']!,
                      role: user['role']!,
                      email: user['email']!,
                      onPressed: () {
                        print('Utilisateur cliqué: ${user['name']}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String role,
    required String email,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image de profil
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/defaultProfileImage.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.background,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Informations utilisateur
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      role,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: role == 'Coach'
                            ? AppColors.green
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
