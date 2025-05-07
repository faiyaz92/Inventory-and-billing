enum Role {
  SUPER_ADMIN,
  COMPANY_ADMIN,
  USER,
}

extension RoleExtension on Role {
  String get name {
    switch (this) {
      case Role.SUPER_ADMIN:
        return 'super_admin';
      case Role.COMPANY_ADMIN:
        return 'company_admin';
      case Role.USER:
        return 'user';
    }
  }

  static Role fromString(String role) {
    switch (role) {
      case 'super_admin':
        return Role.SUPER_ADMIN;
      case 'company_admin':
        return Role.COMPANY_ADMIN;
      case 'user':
        return Role.USER;
      default:
        throw Exception('Invalid role: $role');
    }
  }
}
