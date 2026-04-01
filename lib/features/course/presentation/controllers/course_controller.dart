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

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;

  set focusedDay(DateTime value) {
    if (_focusedDay != value) {
      _focusedDay = value;
      notifyListeners();
    }
  }

  set selectedDay(DateTime value) {
    if (_selectedDay != value) {
      _selectedDay = value;
      notifyListeners();
    }
  }

  List<Course> getCoursesForDay(DateTime day) {
    return courses.where((course) {
      final courseDate = course.startAt.toLocal();
      return courseDate.year == day.year &&
          courseDate.month == day.month &&
          courseDate.day == day.day;
    }).toList();
  }

  Future<void> loadCourses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Charger une plage de 3 mois autour du jour focalisé
      final startDate = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      final endDate = DateTime(_focusedDay.year, _focusedDay.month + 2, 0);

      final response = await CourseService.getAll(
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success) {
        courses = response.data ?? [];
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

      final time =
          '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
      return time;
    } catch (e) {
      return dateTime.toString();
    }
  }
}
