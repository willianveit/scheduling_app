class Mechanic {
  final String id;
  final String name;
  final String? email;
  final String? specialty;

  const Mechanic({required this.id, required this.name, this.email, this.specialty});

  Mechanic copyWith({String? id, String? name, String? email, String? specialty}) {
    return Mechanic(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      specialty: specialty ?? this.specialty,
    );
  }
}
