class TimeSlot {
  int? slotId;
  DateTime startTime;
  DateTime endTime;
  bool isBooked;
  int? bookedBy; // Reference to user who booked the slot
  String? bookedByName; // Name of the user who booked the slot
  String? bookedByContact; // Contact number of the user who booked the slot

  TimeSlot({
    this.slotId,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
    this.bookedBy,
    this.bookedByName,
    this.bookedByContact,
  });

  // Convert a TimeSlot instance into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'slot_id': slotId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_booked': isBooked ? 1 : 0,
      'booked_by': bookedBy,
      'booked_by_name': bookedByName,
      'booked_by_contact': bookedByContact,
    };
  }

  // Extract a TimeSlot object from a Map object
  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      slotId: map['slot_id'] as int?,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      isBooked: (map['is_booked'] as int) == 1,
      bookedBy: map['booked_by'] as int?,
      bookedByName: map['booked_by_name'] as String?,
      bookedByContact: map['booked_by_contact'] as String?,
    );
  }

  // Optionally, create a method to convert the object to JSON if needed for web APIs or local storage
  Map<String, dynamic> toJson() {
    return {
      'slot_id': slotId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_booked': isBooked,
      'booked_by': bookedBy,
      'booked_by_name': bookedByName,
      'booked_by_contact': bookedByContact,
    };
  }
}
