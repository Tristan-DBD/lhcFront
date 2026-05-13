import 'package:flutter/material.dart';
import '../../data/services/individual_session_service.dart';
import '../../../../core/auth/jwt_service.dart';
import '../../data/models/individual_session.dart';

class IndividualSessionController extends ChangeNotifier {
  List<IndividualSession> sessions = [];
  String? errorMessage;
  bool isLoading = true;
  String? userId;
  String? userRole;

  IndividualSessionController() {
    init();
  }

  Future<void> init() async {
    await loadDataForRegistration();
    await loadSessions();
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

  List<IndividualSession> getSessionsForDay(DateTime day) {
    return sessions.where((session) {
      final sessionDate = session.startAt.toLocal();
      return sessionDate.year == day.year &&
          sessionDate.month == day.month &&
          sessionDate.day == day.day;
    }).toList();
  }

  Future<void> loadSessions() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final startDate = DateTime(_focusedDay.year, _focusedDay.month - 1);
      final endDate = DateTime(_focusedDay.year, _focusedDay.month + 2, 0);

      final response = await IndividualSessionService.getAll(
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success) {
        sessions = response.data ?? [];
        sessions.sort((a, b) => a.startAt.compareTo(b.startAt));
      } else {
        sessions = [];
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

  Future<bool> deleteSession(String sessionId) async {
    try {
      final response = await IndividualSessionService.delete(sessionId);
      if (response.success && response.data == true) {
        await loadSessions();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> registerToSession(String sessionId) async {
    if (userId == null) return false;
    try {
      final response =
          await IndividualSessionService.registerToSession(sessionId, userId!);
      if (response.success && response.data == true) {
        await loadSessions();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unregisterFromSession(String sessionId) async {
    if (userId == null) return false;
    try {
      final response = await IndividualSessionService.unregisterFromSession(
        sessionId,
        userId!,
      );
      if (response.success && response.data == true) {
        await loadSessions();
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
