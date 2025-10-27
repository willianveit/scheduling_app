import 'package:scheduling_app/domain/entities/mechanic_availability.dart';

class Mechanic {
  final String id;
  final String name;
  final String? email;
  final String? specialty;
  final List<DayAvailability>? availability;
  final DateTime? availabilityUpdatedAt;

  const Mechanic({
    required this.id,
    required this.name,
    this.email,
    this.specialty,
    this.availability,
    this.availabilityUpdatedAt,
  });

  Mechanic copyWith({
    String? id,
    String? name,
    String? email,
    String? specialty,
    List<DayAvailability>? availability,
    DateTime? availabilityUpdatedAt,
  }) {
    return Mechanic(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      specialty: specialty ?? this.specialty,
      availability: availability ?? this.availability,
      availabilityUpdatedAt: availabilityUpdatedAt ?? this.availabilityUpdatedAt,
    );
  }
}
