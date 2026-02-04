import 'package:flutter/material.dart';
import 'package:lhc_front/screen/create_user.dart';
import 'package:lhc_front/screen/profile_page.dart';
import 'package:lhc_front/services/user.dart';
import '../constant/app_colors.dart';
import '../models/User.dart';

class ListUserPage extends StatefulWidget {
  const ListUserPage({super.key});

  @override
  State<ListUserPage> createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage> {
  List<Map<String, dynamic>> users = [];
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final response = await UserService.getAll();

      if (response['success'] == false) {
        setState(() {
          isLoading = false;
          errorMessage = response['message'] ?? 'Erreur lors du chargement';
        });
        return;
      }

      // Extraire la liste d'utilisateurs de la réponse
      List<Map<String, dynamic>> userList;

      if (response['data'] is List && response['data'].isNotEmpty) {
        userList = List<Map<String, dynamic>>.from(
          response['data'][0]['message'],
        );
        // Trier par ordre croissant de nom
        userList.sort(
          (a, b) => (a['surname'] ?? '').compareTo(b['surname'] ?? ''),
        );
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Format de réponse invalide';
        });
        return;
      }

      setState(() {
        users = userList;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur: $e';
      });
    }
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateUserScreen(),
                ),
              ).then((_) {
                // Rafraîchir la liste quand on revient de la création
                _loadUsers();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (users.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage ?? 'Aucun utilisateur trouvé',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Grille des utilisateurs
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserCard(
                        name: '${user['surname'] ?? ''} ${user['name'] ?? ''}'
                            .trim(),
                        role: user['role'] ?? 'Rôle inconnu',
                        email: user['email'] ?? 'Email inconnu',
                        imageUri: user['imageUri'] ?? 'default.png',
                        onPressed: () {
                          final userObj = User.fromJson(user);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(user: userObj),
                            ),
                          );
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
    required String imageUri,
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
                      'assets/$imageUri',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.background,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: const Color.fromARGB(255, 187, 67, 67),
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
                    _buildRoleBadge(role),
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
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
