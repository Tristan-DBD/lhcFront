import 'package:flutter/material.dart';
import '../../data/services/coaching_slot_service.dart';
import '../../../../core/auth/jwt_service.dart';
import '../../data/models/coaching_slot.dart';

class CoachingSlotController extends ChangeNotifier {
  List<CoachingSlot> slots = [];
  String? errorMessage;
  bool isLoading = true;
  String? processingSlotId;
  String? userId;
  String? userRole;

  CoachingSlotController() {
    init();
  }

  Future<void> init() async {
    await loadDataForRegistration();
    await loadSlots();
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

  List<CoachingSlot> getSlotsForDay(DateTime day) {
    return slots.where((slot) {
      final slotDate = slot.startTime.toLocal();
      return slotDate.year == day.year &&
          slotDate.month == day.month &&
          slotDate.day == day.day;
    }).toList();
  }

  Future<void> loadSlots() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Charger une plage de 3 mois autour du jour focalisé
      final startDate = DateTime(_focusedDay.year, _focusedDay.month - 1);
      final endDate = DateTime(_focusedDay.year, _focusedDay.month + 2, 0);

      final response = await CoachingSlotService.getAll(
        startDate: startDate,
        endDate: endDate,
        coachId: null,
      );

      if (response.success) {
        slots = response.data ?? [];
        // Trier les créneaux par date de début (du plus proche au plus lointain)
        slots.sort((a, b) => a.startTime.compareTo(b.startTime));
      } else {
        slots = [];
        errorMessage = response.errorMessage;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createSlot(Map<String, dynamic> slotData) async {
    try {
      final response = await CoachingSlotService.create(slotData);

      if (response.success) {
        await loadSlots(); // Recharger la liste
        return true;
      } else {
        errorMessage = response.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSlot(String id, Map<String, dynamic> slotData) async {
    try {
      final response = await CoachingSlotService.update(id, slotData);

      if (response.success) {
        await loadSlots(); // Recharger la liste
        return true;
      } else {
        errorMessage = response.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSlot(String id) async {
    try {
      final response = await CoachingSlotService.delete(id);

      if (response.success) {
        await loadSlots(); // Recharger la liste
        return true;
      } else {
        errorMessage = response.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> bookSlot(String slotId) async {
    if (userId == null) {
      errorMessage = 'Utilisateur non connecté';
      notifyListeners();
      return false;
    }

    processingSlotId = slotId;
    notifyListeners();

    try {
      final response = await CoachingSlotService.bookSlot(userId!, slotId);

      if (response.success) {
        await Future.delayed(const Duration(milliseconds: 300));
        await loadSlots(); // Recharger la liste
        processingSlotId = null;
        return true;
      } else {
        errorMessage = response.errorMessage;
        processingSlotId = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      processingSlotId = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(String slotId) async {
    if (userId == null) {
      errorMessage = 'Utilisateur non connecté';
      notifyListeners();
      return false;
    }

    processingSlotId = slotId;
    notifyListeners();

    try {
      final response = await CoachingSlotService.cancelBooking(userId!, slotId);

      if (response.success) {
        await Future.delayed(const Duration(milliseconds: 300));
        await loadSlots(); // Recharger la liste
        processingSlotId = null;
        return true;
      } else {
        errorMessage = response.errorMessage;
        processingSlotId = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      processingSlotId = null;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
