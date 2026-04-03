import '../../../user/data/models/user.dart';

class SlotBooking {
  final int id;
  final int slotId;
  final int userId;
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
      id: json['id'] as int? ?? 0,
      slotId: json['slotId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      bookedAt: json['bookedAt'] != null
          ? DateTime.parse(json['bookedAt'] as String)
          : DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class CoachingSlot {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final int coachId;
  final List<SlotBooking> bookings;

  CoachingSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.coachId,
    this.bookings = const [],
  });

  bool isBookedByUser(int? userId) {
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
      id: json['id'] as int? ?? 0,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : DateTime.now(),
      coachId: json['coachId'] as int? ?? 0,
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
