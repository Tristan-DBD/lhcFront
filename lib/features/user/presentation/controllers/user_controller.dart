import 'package:flutter/material.dart';
import '../../data/services/user_service.dart';
import '../../../../core/auth/jwt_service.dart';
import '../../../../core/theme/user_role.dart';
import '../../data/models/user.dart';
import '../../../../core/api/api_response.dart';

class UserController extends ChangeNotifier {
  List<User> users = [];
  String? errorMessage;
  bool isLoading = true;
  bool canEditPayments = false;

  UserController() {
    init();
  }

  Future<void> init() async {
    await checkUserPermissions();
    await loadUsers();
  }

  Future<void> checkUserPermissions() async {
    final roleStr = await JwtService.getUserRole() ?? '';
    final role = UserRole.fromString(roleStr);
    canEditPayments = role.isCoach || role.isAdmin;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await UserService.getAll();

      if (!response.success) {
        isLoading = false;
        errorMessage = response.errorMessage ?? 'Erreur lors du chargement';
        notifyListeners();
        return;
      }

      if (response.data != null) {
        users = response.data!;
        // Trier par ordre croissant de nom (surname)
        users.sort((a, b) => a.surname.compareTo(b.surname));
      } else {
        users = [];
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Erreur: $e';
      notifyListeners();
    }
  }

  Future<ApiResponse<User>> createUser(Map<String, dynamic> userData) async {
    return await UserService.create(userData);
  }

  void updateUserInList(User updatedUser) {
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      notifyListeners();
    }
  }
}
