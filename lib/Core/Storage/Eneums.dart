enum UserRole {
  admin,
  agent,
  client,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return "ADMIN";
      case UserRole.agent:
        return "AGENT";
      case UserRole.client:
        return "CLIENT";
    }
  }

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case "ADMIN":
        return UserRole.admin;
      case "AGENT":
        return UserRole.agent;
      case "CLIENT":
        return UserRole.client;
      default:
        throw Exception("Unknown role: $role");
    }
  }
}