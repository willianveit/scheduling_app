enum UserRole {
  client,
  mechanic;

  String toJson() => name;

  static UserRole fromJson(String json) {
    return UserRole.values.firstWhere((role) => role.name == json, orElse: () => UserRole.client);
  }
}
