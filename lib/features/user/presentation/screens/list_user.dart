import 'package:flutter/material.dart';
import 'package:lhc_front/features/user/presentation/controllers/user_controller.dart';
import 'create_user.dart';
import '../../../shared/presentation/screens/profile_page.dart';
import '../../data/models/user.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/role_badge.dart';

class ListUserPage extends StatefulWidget {
  const ListUserPage({super.key});

  @override
  State<ListUserPage> createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage> {
  late final UserController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UserController();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Liste des utilisateurs',
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
            actions: [
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateUserScreen(),
                    ),
                  ).then((_) {
                    _controller.loadUsers();
                  });
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(
                ResponsiveHelper.getHorizontalPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_controller.isLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_controller.users.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _controller.errorMessage ??
                                  'Aucun utilisateur trouvé',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              ResponsiveHelper.getGridCrossAxisCount(
                                context,
                                mobile: 2,
                                tablet: 3,
                              ),
                          crossAxisSpacing: ResponsiveHelper.getGridSpacing(
                            context,
                          ),
                          mainAxisSpacing: ResponsiveHelper.getGridSpacing(
                            context,
                          ),
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _controller.users.length,
                        itemBuilder: (context, index) {
                          final user = _controller.users[index];
                          return _buildUserCard(
                            name: user.fullName,
                            role: user.role,
                            imageUri: user.imageUri,
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                    user: user,
                                    canEditPayments:
                                        _controller.canEditPayments,
                                  ),
                                ),
                              );

                              if (result != null && result is User) {
                                _controller.updateUserInList(result);
                              }
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
      },
    );
  }

  Widget _buildUserCard({
    required String name,
    required String role,
    required String imageUri,
    required VoidCallback onPressed,
  }) {
    return AppCard(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: ImageHelper.profileImage(imageUri),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  RoleBadge(role: role),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
