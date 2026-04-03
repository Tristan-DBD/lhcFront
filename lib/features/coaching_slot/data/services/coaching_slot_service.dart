import 'package:lhc_front/core/api/api_response.dart';
import '../models/coaching_slot.dart';
import '../../../../core/api/http_client.dart';
import '../../../user/data/services/user_service.dart';
import '../../../user/data/models/user.dart';

class CoachingSlotService {
  static Future<ApiResponse<CoachingSlot>> create(
    Map<String, dynamic> slotData,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post('/coaching-slots', body: slotData);

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        final slotMap = data['message'] ?? data;
        return ApiResponse.success(CoachingSlot.fromJson(slotMap));
      }

      return ApiResponse.error(
        _extractErrorMessage(response) ??
            'Erreur lors de la création du créneau',
      );
    } catch (e) {
      return ApiResponse.error('Erreur lors de la création du créneau: $e');
    }
  }

  static Future<ApiResponse<List<CoachingSlot>>> getAll({
    DateTime? startDate,
    DateTime? endDate,
    String? coachId,
  }) async {
    try {
      final httpClient = HttpClient();
      final queryParams = _buildQueryParams(startDate, endDate, coachId);
      final response = await httpClient.get('/coaching-slots$queryParams');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        final slots = dataList
            .map((item) => CoachingSlot.fromJson(item))
            .toList();
        return ApiResponse.success(slots);
      }

      return ApiResponse.error(
        response['message'] ?? 'Erreur lors de la récupération des créneaux',
      );
    } catch (e) {
      return ApiResponse.error(
        'Erreur lors de la récupération des créneaux: $e',
      );
    }
  }

  static Future<ApiResponse<CoachingSlot>> getById(String id) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get('/coaching-slots/$id');

      if (response['success'] == true && response['data'] != null) {
        return ApiResponse.success(CoachingSlot.fromJson(response['data']));
      }

      return ApiResponse.error(response['message'] ?? 'Créneau non trouvé');
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération du créneau: $e');
    }
  }

  static Future<ApiResponse<CoachingSlot>> update(
    String id,
    Map<String, dynamic> slotData,
  ) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.put(
        '/coaching-slots/$id',
        body: slotData,
      );

      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final data = response['data'][0];
        final slotMap = data['message'] ?? data;
        return ApiResponse.success(CoachingSlot.fromJson(slotMap));
      }

      String? errorMsg;
      if (response['data'] != null && (response['data'] as List).isNotEmpty) {
        errorMsg = response['data'][0]['message']?.toString();
      }
      return ApiResponse.error(
        errorMsg ??
            response['message'] ??
            'Erreur lors de la mise à jour du créneau',
      );
    } catch (e) {
      return ApiResponse.error('Erreur lors de la mise à jour du créneau: $e');
    }
  }

  static Future<ApiResponse<bool>> delete(String id) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.delete('/coaching-slots/$id');

      if (response['success'] == true) {
        return ApiResponse.success(true);
      }

      return ApiResponse.error(
        response['message'] ?? 'Erreur lors de la suppression du créneau',
      );
    } catch (e) {
      return ApiResponse.error('Erreur lors de la suppression du créneau: $e');
    }
  }

  static Future<ApiResponse<bool>> bookSlot(String userId, String slotId) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post(
        '/coaching-slots/book',
        body: {'userId': userId, 'slotId': slotId},
      );

      if (response['success'] == true) {
        return ApiResponse.success(true);
      }

      return ApiResponse.error(
        response['message'] ?? 'Erreur lors de la réservation du créneau',
      );
    } catch (e) {
      return ApiResponse.error('Erreur lors de la réservation du créneau: $e');
    }
  }

  static Future<ApiResponse<bool>> cancelBooking(String userId, String slotId) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post(
        '/coaching-slots/cancel',
        body: {'userId': userId, 'slotId': slotId},
      );

      if (response['success'] == true) {
        return ApiResponse.success(true);
      }

      return ApiResponse.error(
        response['message'] ?? 'Erreur lors de l\'annulation de la réservation',
      );
    } catch (e) {
      return ApiResponse.error(
        'Erreur lors de l\'annulation de la réservation: $e',
      );
    }
  }

  static Future<ApiResponse<List<SlotBooking>>> getBookings(String slotId) async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get('/coaching-slots/bookings/$slotId');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        final bookings = dataList
            .map((item) => SlotBooking.fromJson(item))
            .toList();
        return ApiResponse.success(bookings);
      }

      return ApiResponse.error(
        response['message'] ??
            'Erreur lors de la récupération des réservations',
      );
    } catch (e) {
      return ApiResponse.error(
        'Erreur lors de la récupération des réservations: $e',
      );
    }
  }

  static Future<List<User>> getAllCoaches() async {
    try {
      final response = await UserService.getAllCoach();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Helper methods
  static String _buildQueryParams(
    DateTime? startDate,
    DateTime? endDate,
    String? coachId,
  ) {
    final params = <String>[];

    if (startDate != null && endDate != null) {
      params.add('startDate=${startDate.toUtc().toIso8601String()}');
      params.add('endDate=${endDate.toUtc().toIso8601String()}');
    }

    if (coachId != null) {
      params.add('coachId=$coachId');
    }

    return params.isNotEmpty ? '?${params.join('&')}' : '';
  }

  static String? _extractErrorMessage(Map<String, dynamic> response) {
    if (response['data'] != null && (response['data'] as List).isNotEmpty) {
      return response['data'][0]['message']?.toString();
    }
    return response['message']?.toString();
  }
}
