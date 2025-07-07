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
  final UserType? userType; // Nullable
  final double? latitude;
  final double? longitude;
  final double? dailyWage;
  final String? storeId;
  final String? accountLedgerId;

  const UserInfo({
    this.userId,
    this.companyId,
    this.name,
    this.email,
    this.userName,
    this.role,
    this.userType, // Optional
    this.latitude,
    this.longitude,
    this.dailyWage,
    this.storeId,
    this.accountLedgerId,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final userTypeRaw = json['userType'] as String?;
    final userType = UserTypeExtension.fromString(userTypeRaw) ?? UserType.Customer; // Default to Customer
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
      'userType': userType?.name, // Serialize as string
      'latitude': latitude,
      'longitude': longitude,
      'dailyWage': dailyWage,
      'storeId': storeId,
      'accountLedgerId': accountLedgerId,
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
      userType: userType ?? UserType.Customer, // Default to Customer
      latitude: latitude,
      longitude: longitude,
      dailyWage: dailyWage,
      storeId: storeId,
      accountLedgerId: accountLedgerId,
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
  ];
}