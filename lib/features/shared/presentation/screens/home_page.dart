import 'package:flutter/material.dart';
import 'package:lhc_front/features/course/presentation/screens/list_course.dart';
import 'package:lhc_front/features/user/presentation/screens/list_user.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/feature_card.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/auth/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'LHC Coaching',
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
            Icons.logout,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => AuthService.logout(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveHelper.getHorizontalPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section de bienvenue
              AppCard(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Bienvenue !',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Retrouvez tous vos outils de coaching',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Section des fonctionnalités
              Text(
                'Fonctionnalités',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 20),

              // Grid des fonctionnalités
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: GridView.count(
                    crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(
                      context,
                    ),
                    crossAxisSpacing: ResponsiveHelper.getGridSpacing(context),
                    mainAxisSpacing: ResponsiveHelper.getGridSpacing(context),
                    children: [
                      FeatureCard(
                        icon: Icons.people,
                        title: 'Liste des utilisateurs',
                        description: 'Gérer les membres',
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const ListUserPage(),
                            ),
                          );
                        },
                      ),
                      FeatureCard(
                        icon: Icons.groups,
                        title: 'Cours collectifs',
                        description: 'Planning des sessions',
                        color: Theme.of(context).colorScheme.secondary,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const ListCoursePage(),
                            ),
                          );
                        },
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
}
