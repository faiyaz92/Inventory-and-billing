enum UserType { Employee, Supplier, Customer, Boss, ThirdPartyVendor, Contractor }

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
    }
  }

  static UserType? fromString(String? name) {
    switch (name?.toLowerCase()) {
      case 'employee':
        return UserType.Employee;
      case 'supplier':
        return UserType.Supplier;
      case 'customer':
        return UserType.Customer;
      case 'boss':
        return UserType.Boss;
      case 'thirdpartyvendor':
        return UserType.ThirdPartyVendor;
      case 'contractor':
        return UserType.Contractor;
      default:
        return null;
    }
  }
}
