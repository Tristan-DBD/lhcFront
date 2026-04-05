import '../../../user/data/models/user.dart';

class SlotBooking {
  final String id;
  final String slotId;
  final String userId;
  final User? user;
  final DateTime bookedAt;

  SlotBooking({
    required this.id,
    required this.slotId,
    required this.userId,
    required this.bookedAt,
    this.user,
  });

  factory SlotBooking.fromJson(Map<String, dynamic> json) {
    return SlotBooking(
      id: json['id'] as String? ?? '0',
      slotId: json['slotId'] as String? ?? '0',
      userId: json['userId'] as String? ?? '0',
      bookedAt: json['bookedAt'] != null
          ? DateTime.parse(json['bookedAt'] as String)
          : DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class CoachingSlot {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String coachId;
  final User? coach;
  final List<SlotBooking> bookings;

  CoachingSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.coachId,
    this.coach,
    this.bookings = const [],
  });

  bool isBookedByUser(String? userId) {
    if (userId == null) return false;
    return bookings.any((booking) => booking.userId == userId);
  }

  bool isAvailable() {
    return bookings.isEmpty;
  }

  factory CoachingSlot.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? bookingJson = json['bookings'];
    final bookings = bookingJson != null
        ? bookingJson.map((b) => SlotBooking.fromJson(b)).toList()
        : <SlotBooking>[];

    return CoachingSlot(
      id: json['id'] as String? ?? '0',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String).toLocal()
          : DateTime.now(),
      coachId: json['coachId'] as String? ?? '0',
      coach: json['coach'] != null ? User.fromJson(json['coach']) : null,
      bookings: bookings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'coachId': coachId,
    };
  }

  @override
  String toString() {
    return 'CoachingSlot(id: $id, bookings: ${bookings.length})';
  }
}
