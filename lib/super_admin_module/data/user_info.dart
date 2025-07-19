import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

class UserInfo extends Equatable {
  final String? userId;
  final String? companyId;
  final String? name;
  final String? email;
  final String? userName;
  final Role? role;
  final UserType? userType;
  final double? latitude;
  final double? longitude;
  final double? dailyWage;
  final String? storeId;
  final String? accountLedgerId;
  final String? mobileNumber;
  final String? businessName;
  final String? address;
  final AccountType? accountType; // New field for account type

  const UserInfo({
    this.userId,
    this.companyId,
    this.name,
    this.email,
    this.userName,
    this.role,
    this.userType,
    this.latitude,
    this.longitude,
    this.dailyWage,
    this.storeId,
    this.accountLedgerId,
    this.mobileNumber,
    this.businessName,
    this.address,
    this.accountType,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final userTypeRaw = json['userType'] as String?;
    final userType = UserTypeExtension.fromString(userTypeRaw) ?? UserType.Customer;
    if (userTypeRaw != null && userType == UserType.Customer) {
      print('UserInfo.fromJson: Defaulted userType to Customer for raw value "$userTypeRaw"');
    }
    return UserInfo(
      userId: json['userId'] as String?,
      companyId: json['companyId'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      userName: json['userName'] as String?,
      role: json['role'] != null ? RoleExtension.fromString(json['role']) : null,
      userType: userType,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      dailyWage: (json['dailyWage'] as num?)?.toDouble() ?? 500.0,
      storeId: json['storeId'] as String?,
      accountLedgerId: json['accountLedgerId'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      businessName: json['businessName'] as String?,
      address: json['address'] as String?,
      accountType: json['accountType'] != null ? AccountTypeExtension.fromString(json['accountType']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'companyId': companyId,
      'name': name,
      'email': email,
      'userName': userName,
      'role': role?.name,
      'userType': userType?.name,
      'latitude': latitude,
      'longitude': longitude,
      'dailyWage': dailyWage,
      'storeId': storeId,
      'accountLedgerId': accountLedgerId,
      'mobileNumber': mobileNumber,
      'businessName': businessName,
      'address': address,
      'accountType': accountType?.name,
    };
  }

  UserInfo copyWith({
    String? userId,
    String? companyId,
    String? name,
    String? email,
    String? userName,
    Role? role,
    UserType? userType,
    double? latitude,
    double? longitude,
    double? dailyWage,
    String? storeId,
    String? accountLedgerId,
    String? mobileNumber,
    String? businessName,
    String? address,
    AccountType? accountType,
  }) {
    return UserInfo(
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      userType: userType ?? this.userType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dailyWage: dailyWage ?? this.dailyWage,
      storeId: storeId ?? this.storeId,
      accountLedgerId: accountLedgerId ?? this.accountLedgerId,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      accountType: accountType ?? this.accountType,
    );
  }

  UserInfoDto toDto() {
    return UserInfoDto(
      userId: userId ?? '',
      companyId: companyId,
      name: name ?? '',
      email: email ?? '',
      userName: userName ?? '',
      role: role ?? Role.USER,
      userType: userType ?? UserType.Customer,
      latitude: latitude,
      longitude: longitude,
      dailyWage: dailyWage,
      storeId: storeId,
      accountLedgerId: accountLedgerId,
      mobileNumber: mobileNumber,
      businessName: businessName,
      address: address,
      accountType: accountType,
    );
  }

  factory UserInfo.fromDto(UserInfoDto dto) {
    return UserInfo(
      userId: dto.userId,
      companyId: dto.companyId,
      name: dto.name,
      email: dto.email,
      userName: dto.userName,
      role: dto.role,
      userType: dto.userType,
      latitude: dto.latitude,
      longitude: dto.longitude,
      dailyWage: dto.dailyWage,
      storeId: dto.storeId,
      accountLedgerId: dto.accountLedgerId,
      mobileNumber: dto.mobileNumber,
      businessName: dto.businessName,
      address: dto.address,
      accountType: dto.accountType,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    companyId,
    name,
    email,
    userName,
    role,
    userType,
    latitude,
    longitude,
    dailyWage,
    storeId,
    accountLedgerId,
    mobileNumber,
    businessName,
    address,
    accountType,
  ];
}