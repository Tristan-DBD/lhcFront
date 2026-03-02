import 'package:flutter/material.dart';
import '../../data/services/course_service.dart';
import '../../../../core/auth/jwt_service.dart';
import '../../data/models/course.dart';

class CourseController extends ChangeNotifier {
  List<Course> courses = [];
  String? errorMessage;
  bool isLoading = true;
  int? userId;
  String? userRole;

  CourseController() {
    init();
  }

  Future<void> init() async {
    await loadDataForRegistration();
    await loadCourses();
  }

  Future<void> loadDataForRegistration() async {
    userId = await JwtService.getUserId();
    userRole = await JwtService.getUserRole();
    notifyListeners();
  }

  Future<void> loadCourses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await CourseService.getAll();
      if (!response.success) {
        isLoading = false;
        errorMessage = response.errorMessage ?? 'Erreur lors du chargement';
        notifyListeners();
        return;
      }

      if (response.data != null) {
        courses = response.data!;
        // Trier les cours par date de début (du plus proche au plus lointain)
        courses.sort((a, b) => a.startAt.compareTo(b.startAt));
      } else {
        courses = [];
      }

      isLoading = false;
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Erreur: $e';
      notifyListeners();
    }
  }

  Future<bool> deleteCourse(int courseId) async {
    try {
      final response = await CourseService.delete(courseId);
      if (response.success && response.data == true) {
        await loadCourses();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> registerToCourse(int courseId) async {
    if (userId == null) return false;
    try {
      final response = await CourseService.registerToCourse(courseId, userId!);
      if (response.success && response.data == true) {
        await loadCourses();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unregisterFromCourse(int courseId) async {
    if (userId == null) return false;
    try {
      final response = await CourseService.unregisterFromCourse(
        courseId,
        userId!,
      );
      if (response.success && response.data == true) {
        await loadCourses();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  String formatDateTime(DateTime dateTime) {
    try {
      final localDateTime = dateTime.toLocal();

      final date =
          '${localDateTime.day.toString().padLeft(2, '0')}/${localDateTime.month.toString().padLeft(2, '0')}/${localDateTime.year}';
      final time =
          '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
      return '$date à $time';
    } catch (e) {
      return dateTime.toString();
    }
  }
}
