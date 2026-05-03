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
  bool isLoadMoreLoading = false;
  bool canEditPayments = false;
  List<String> selectedRoles = [];

  // Pagination
  int currentPage = 1;
  bool hasNextPage = false;
  final int limit = 20;

  Future<void> init() async {
    // On s'assure que le chargement est bien marqué
    isLoading = true;
    notifyListeners();

    await checkUserPermissions();
    await loadUsers();
  }

  void toggleRoleFilter(String role) {
    if (selectedRoles.contains(role)) {
      selectedRoles.remove(role);
    } else {
      selectedRoles.add(role);
    }
    loadUsers();
  }

  Future<void> checkUserPermissions() async {
    final roleStr = await JwtService.getUserRole() ?? '';
    final role = UserRole.fromString(roleStr);
    canEditPayments = role.isCoach || role.isAdmin;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    isLoading = true;
    currentPage = 1;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await UserService.getAll(
        roles: selectedRoles,
        page: currentPage,
        limit: limit,
      );

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

        // Mettre à jour la pagination
        if (response.pagination != null) {
          hasNextPage = response.pagination!['hasNext'] ?? false;
        }
      } else {
        users = [];
        hasNextPage = false;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Erreur: $e';
      notifyListeners();
    }
  }

  Future<void> loadMoreUsers() async {
    if (isLoadMoreLoading || !hasNextPage) return;

    isLoadMoreLoading = true;
    notifyListeners();

    try {
      final nextPage = currentPage + 1;
      final response = await UserService.getAll(
        roles: selectedRoles,
        page: nextPage,
        limit: limit,
      );

      if (response.success && response.data != null) {
        final newUsers = response.data!;
        users.addAll(newUsers);
        // Trier à nouveau après ajout
        users.sort((a, b) => a.surname.compareTo(b.surname));

        currentPage = nextPage;
        if (response.pagination != null) {
          hasNextPage = response.pagination!['hasNext'] ?? false;
        }
      }

      isLoadMoreLoading = false;
      notifyListeners();
    } catch (e) {
      isLoadMoreLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse<User>> createUser(Map<String, dynamic> userData) {
    return UserService.create(userData);
  }

  void updateUserInList(User updatedUser) {
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      notifyListeners();
    }
  }
}
