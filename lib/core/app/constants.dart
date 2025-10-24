enum UserRole {
  student,
  teacher,
  admin;

  // Helper to convert string from Firestore to an enum
  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.student, // Default fallback
    );
  }
}

enum UserStatus {
  online,
  offline;

  // Helper to convert string from Firestore to an enum
  static UserStatus fromString(String status) {
    return UserStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => UserStatus.offline, // Default fallback
    );
  }
}

enum Gender {
  male,
  female,
  other;

  // Helper to convert string from Firestore to an enum
  static Gender fromString(String gender) {
    return Gender.values.firstWhere(
      (e) => e.name == gender,
      orElse: () => Gender.other, // Default fallback
    );
  }
}
