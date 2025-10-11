enum AppointmentStatus {
  available,
  scheduled,
  canceled,
  completed;

  String toJson() => name;

  static AppointmentStatus fromJson(String json) {
    return AppointmentStatus.values.firstWhere(
      (status) => status.name == json,
      orElse: () => AppointmentStatus.available,
    );
  }
}
