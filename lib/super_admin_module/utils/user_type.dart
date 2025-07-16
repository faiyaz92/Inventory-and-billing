enum UserType { Employee, Supplier, Customer, Boss, ThirdPartyVendor, Contractor, Store }

extension UserTypeExtension on UserType {
  String get name {
    switch (this) {
      case UserType.Employee:
        return 'Employee';
      case UserType.Supplier:
        return 'Supplier';
      case UserType.Customer:
        return 'Customer';
      case UserType.Boss:
        return 'Boss';
      case UserType.ThirdPartyVendor:
        return 'ThirdPartyVendor';
      case UserType.Contractor:
        return 'Contractor';
      case UserType.Store:
        return 'Store';
    }
  }

  static UserType? fromString(String? name) {
    if (name == null || name.trim().isEmpty) {
      print('UserTypeExtension: Null or empty userType string');
      return null;
    }
    final normalized = name.trim().toLowerCase();
    switch (normalized) {
      case 'employee':
      case 'Employee':
      case 'EMPLOYEE':
        return UserType.Employee;
      case 'supplier':
      case 'Supplier':
      case 'SUPPLIER':
        return UserType.Supplier;
      case 'customer':
      case 'Customer':
      case 'CUSTOMER':
        return UserType.Customer;
      case 'boss':
      case 'Boss':
      case 'BOSS':
        return UserType.Boss;
      case 'thirdpartyvendor':
      case 'ThirdPartyVendor':
      case 'THIRDPARTYVENDOR':
      case 'third_party_vendor':
        return UserType.ThirdPartyVendor;
      case 'contractor':
      case 'Contractor':
      case 'CONTRACTOR':
        return UserType.Contractor;
      case 'store':
      case 'Store':
      case 'STORE':
        return UserType.Store;
      default:
        print('UserTypeExtension: Unknown userType "$name"');
        return null;
    }
  }
}