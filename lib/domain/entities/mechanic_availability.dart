class WorkPeriod {
  final String startTime; // Format: "HH:mm"
  final String endTime; // Format: "HH:mm"

  const WorkPeriod({required this.startTime, required this.endTime});

  Map<String, dynamic> toJson() {
    return {'startTime': startTime, 'endTime': endTime};
  }

  factory WorkPeriod.fromJson(Map<String, dynamic> json) {
    return WorkPeriod(startTime: json['startTime'] as String, endTime: json['endTime'] as String);
  }
}

class DayAvailability {
  final DateTime date;
  final List<WorkPeriod> workPeriods;

  const DayAvailability({required this.date, required this.workPeriods});

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'workPeriods': workPeriods.map((p) => p.toJson()).toList(),
    };
  }

  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    return DayAvailability(
      date: DateTime.parse(json['date'] as String),
      workPeriods: (json['workPeriods'] as List)
          .map((p) => WorkPeriod.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MechanicAvailability {
  final String mechanicId;
  final String storeId;
  final List<DayAvailability> availability;
  final DateTime updatedAt;

  const MechanicAvailability({
    required this.mechanicId,
    required this.storeId,
    required this.availability,
    required this.updatedAt,
  });

  MechanicAvailability copyWith({
    String? mechanicId,
    String? storeId,
    List<DayAvailability>? availability,
    DateTime? updatedAt,
  }) {
    return MechanicAvailability(
      mechanicId: mechanicId ?? this.mechanicId,
      storeId: storeId ?? this.storeId,
      availability: availability ?? this.availability,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
