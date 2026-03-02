import 'package:flutter/material.dart';
import '../../core/theme/user_role.dart';
import '../../features/shared/presentation/screens/home_page.dart';
import '../../features/shared/presentation/screens/profile_page.dart';
import '../../features/user/presentation/screens/login_page.dart';
import '../../features/user/data/models/user.dart';
import '../auth/jwt_service.dart';
import '../../features/user/data/services/user_service.dart';

class NavigationHelper {
  static Future<void> initNavigation(BuildContext context) async {
    final bool isLoggedIn = await JwtService.isTokenValid();

    if (isLoggedIn) {
      final roleStr = await JwtService.getUserRole() ?? '';
      final role = UserRole.fromString(roleStr);

      if (role.isCoach || role.isAdmin) {
        navigator(context, const HomePage());
      } else {
        final loggedUser = await getUserData();
        if (loggedUser != null) {
          navigator(context, ProfilePage(user: loggedUser));
        } else {
          navigator(context, const LoginPage());
        }
      }
    } else {
      navigator(context, const LoginPage());
    }
  }

  static void navigator(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static Future<User?> getUserData() async {
    final userId = await JwtService.getUserId();
    if (userId == null) return null;
    final response = await UserService.getUserById(userId);
    return response.success ? response.data : null;
  }
}
