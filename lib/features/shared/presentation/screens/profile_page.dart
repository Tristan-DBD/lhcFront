import 'package:flutter/material.dart';
import '../../../../core/auth/auth_service.dart';
import 'package:lhc_front/features/course/presentation/screens/list_course.dart';
import '../../../../core/auth/jwt_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../user/presentation/screens/edit_user.dart';
import '../../../user/presentation/screens/programme_page.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../user/data/models/user.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../user/presentation/widgets/payment_history_grid.dart';
import '../../../../core/widgets/atoms/info_tile.dart';
import '../../../../core/widgets/atoms/stat_display.dart';
import '../../../../core/theme/user_role.dart';
import '../../../user/data/services/payment_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.user,
    super.key,
    this.canEditPayments = false,
  });

  final User user;
  final bool canEditPayments;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _currentUser;
  late Map<String, bool> _payments;
  bool _isViewerManager = false;

  int? _viewerId;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _initializePayments();
    _checkViewerRole();
  }

  Future<void> _checkViewerRole() async {
    final roleStr = await JwtService.getUserRole() ?? '';
    final id = await JwtService.getUserId();
    final role = UserRole.fromString(roleStr);
    if (mounted) {
      setState(() {
        _isViewerManager = role.isCoach || role.isAdmin;
        _viewerId = id;
      });
    }
  }

  void _initializePayments() {
    final currentYear = DateTime.now().year;
    // Trouver les paiements pour l'année en cours
    final paymentYear = _currentUser.payments.firstWhere(
      (p) => p['year'] == currentYear,
      orElse: () => {},
    );

    if (paymentYear.isNotEmpty && paymentYear['status'] != null) {
      _payments = Map<String, bool>.from(paymentYear['status']);
    } else {
      // Fallback si pas de données
      _payments = {
        'jan': false,
        'feb': false,
        'mar': false,
        'apr': false,
        'may': false,
        'jun': false,
        'jul': false,
        'aug': false,
        'sep': false,
        'oct': false,
        'nov': false,
        'dec': false,
      };
    }
  }

  Future<void> _handlePaymentToggle(String month) async {
    final currentYear = DateTime.now().year;
    final response = await PaymentService.toggleMonth(
      userId: _currentUser.id,
      year: currentYear,
      month: month,
    );

    if (!response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.errorMessage ?? 'Erreur inconnue')),
        );
        // Revert local state if needed (the widget already toggled it visually)
        setState(() {
          _initializePayments();
        });
      }
    } else {
      // Mettre à jour l'utilisateur local avec les nouvelles données de paiement
      final updatedPayments = List<Map<String, dynamic>>.from(
        _currentUser.payments,
      );
      final index = updatedPayments.indexWhere((p) => p['year'] == currentYear);
      if (index != -1) {
        updatedPayments[index] = response.data!;
      } else {
        updatedPayments.add(response.data!);
      }

      setState(() {
        _currentUser = _currentUser.copyWith(payments: updatedPayments);
        _initializePayments();
      });
    }
  }

  UserRole get _currentRole => UserRole.fromString(_currentUser.role);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // ensure result is passed back if system back button is used
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Profil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          leading: _isViewerManager
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context, _currentUser),
                )
              : (_viewerId == _currentUser.id
                    ? IconButton(
                        icon: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () => AuthService.logout(context),
                      )
                    : null),
          actions: [
            IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditUserScreen(user: _currentUser),
                  ),
                );

                if (result != null && result is User) {
                  setState(() {
                    _currentUser = result;
                    _initializePayments();
                  });
                }
              },
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.onSurface,
              ),
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
                  height: ResponsiveHelper.isMobile(context) ? 150 : 200,
                  decoration: BoxDecoration(
                    color: AppColors.current.background,
                  ),
                  child: Center(
                    child: Container(
                      width: ResponsiveHelper.isMobile(context) ? 120 : 160,
                      height: ResponsiveHelper.isMobile(context) ? 120 : 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(75),
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
                        borderRadius: BorderRadius.circular(75),
                        child: ImageHelper.profileImage(_currentUser.imageUri),
                      ),
                    ),
                  ),
                ),

                // Prénom et Nom
                AppCard(
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getHorizontalPadding(context),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      ResponsiveHelper.isMobile(context) ? 16 : 20,
                    ),
                    child: Column(
                      children: [
                        Text(
                          _currentUser.fullName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.current.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (_currentRole.isCoach)
                          RoleBadge(role: _currentUser.role),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                if (!_currentRole.isAthleteCo)
                  // Stats de force
                  AppCard(
                    margin: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getHorizontalPadding(
                        context,
                      ),
                    ),
                    padding: EdgeInsets.all(
                      ResponsiveHelper.isMobile(context) ? 16 : 20,
                    ),
                    child: Column(children: [_buildStatsRow()]),
                  ),
                SizedBox(height: ResponsiveHelper.isMobile(context) ? 20 : 30),

                // Informations supplémentaires
                AppCard(
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getHorizontalPadding(context),
                  ),
                  padding: EdgeInsets.all(
                    ResponsiveHelper.isMobile(context) ? 16 : 20,
                  ),
                  child: Column(
                    children: [
                      InfoTile(
                        icon: Icons.phone,
                        label: 'Téléphone',
                        value: _currentUser.phone,
                      ),
                      const SizedBox(height: 16),
                      InfoTile(
                        icon: Icons.cake,
                        label: 'Âge',
                        value: '${_currentUser.age} ans',
                      ),
                      const SizedBox(height: 16),
                      InfoTile(
                        icon: Icons.monitor_weight,
                        label: 'Poids',
                        value: '${_currentUser.weight} kg',
                      ),
                    ],
                  ),
                ),

                if (_currentUser.role.toUpperCase().startsWith('ATHLETE')) ...[
                  SizedBox(
                    height: ResponsiveHelper.isMobile(context) ? 20 : 30,
                  ),
                  PaymentHistoryGrid(
                    initialPayments: _payments,
                    isEditable: _isViewerManager,
                    onMonthTap: _handlePaymentToggle,
                  ),
                ],

                SizedBox(height: ResponsiveHelper.isMobile(context) ? 20 : 30),

                AppCard(
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getHorizontalPadding(context),
                  ),
                  padding: EdgeInsets.all(
                    ResponsiveHelper.isMobile(context) ? 16 : 20,
                  ),
                  child: Column(
                    children: [
                      // si role = COACH, ATHLETE_PROG ou ATHLETE_FULL affiche le bouton pour les programmes
                      if (_currentRole.isAthleteProg ||
                          _currentRole.isAthleteFull ||
                          _currentRole.isCoach ||
                          _currentRole.isAdmin)
                        _buildOptionRow(
                          label: 'Programmes',
                          page: ProgrammePage(
                            user: _currentUser,
                            isManager: _isViewerManager,
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
                      if (_currentRole.isAthleteCo ||
                          _currentRole.isAthleteFull ||
                          _currentRole.isCoach ||
                          _currentRole.isAdmin)
                        const SizedBox(height: 20),
                      if (_currentRole.isAthleteCo ||
                          _currentRole.isAthleteFull ||
                          _currentRole.isCoach ||
                          _currentRole.isAdmin)
                        _buildOptionRow(
                          label: 'Cours Collectifs',
                          page: const ListCoursePage(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow({required String label, required Widget page}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatDisplay(label: 'Squat', value: _getStatValue('squat')),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: StatDisplay(label: 'Bench', value: _getStatValue('bench')),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: StatDisplay(
            label: 'Deadlift',
            value: _getStatValue('deadlift'),
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
