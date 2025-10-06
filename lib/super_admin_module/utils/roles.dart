enum Role {
  SUPER_ADMIN,
  COMPANY_ADMIN,
  USER,
  STORE_ADMIN,
  SALES_MAN, // New role
  DELIVERY_MAN, // New role
  STORE_ACCOUNTANT, // New role
  STORE_MANAGER, // New role
  COMPANY_ACCOUNTANT, // New role
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
      case Role.STORE_ADMIN:
        return 'store_admin';
      case Role.SALES_MAN:
        return 'sales_man';
      case Role.DELIVERY_MAN:
        return 'delivery_man';
      case Role.STORE_ACCOUNTANT:
        return 'store_accountant';
      case Role.STORE_MANAGER:
        return 'store_manager';
      case Role.COMPANY_ACCOUNTANT:
        return 'company_accountant';
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
      case 'store_admin':
        return Role.STORE_ADMIN;
      case 'sales_man':
        return Role.SALES_MAN;
      case 'delivery_man':
        return Role.DELIVERY_MAN;
      case 'store_accountant':
        return Role.STORE_ACCOUNTANT;
      case 'store_manager':
        return Role.STORE_MANAGER;
      case 'company_accountant':
        return Role.COMPANY_ACCOUNTANT;
      default:
        throw Exception('Invalid role: $role');
    }
  }
}
