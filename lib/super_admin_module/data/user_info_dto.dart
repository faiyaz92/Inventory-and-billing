import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

class UserInfoDto extends Equatable {
  final String userId;
  final String? companyId;
  final String name;
  final String email;
  final String userName;
  final Role role;
  final UserType? userType; // New field
  final double? latitude;
  final double? longitude;
  final double? dailyWage;
  final String? storeId;
  final String? accountLedgerId;

  const UserInfoDto({
    required this.userId,
    this.companyId,
    required this.name,
    required this.email,
    required this.userName,
    required this.role,
    this.userType, // New field
    this.latitude,
    this.longitude,
    this.dailyWage,
    this.storeId,
    this.accountLedgerId,
  });

  factory UserInfoDto.fromMap(Map<String, dynamic> map) {
    return UserInfoDto(
      userId: map['userId'] as String,
      companyId: map['companyId'] as String?,
      name: map['name'] as String,
      email: map['email'] as String,
      userName: map['userName'] as String,
      role: RoleExtension.fromString(map['role'] as String),
      userType: map.containsKey('userType')
          ? UserTypeExtension.fromString(map['userType'] as String)
          : UserType.Employee,
      // New field
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      dailyWage: (map['dailyWage'] as num?)?.toDouble() ?? 500.0,
      storeId: map['storeId'] as String?,
      accountLedgerId: map['accountLedgerId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'companyId': companyId,
      'name': name,
      'email': email,
      'userName': userName,
      'role': role.name,
      'userType': userType, // New field
      'latitude': latitude,
      'longitude': longitude,
      'dailyWage': dailyWage,
      'storeId': storeId,
      'accountLedgerId': accountLedgerId,
    };
  }

  Map<String, dynamic> toPartialMap() {
    final map = <String, dynamic>{};
    map['userId'] = userId; // Always include userId
    if (companyId != null) map['companyId'] = companyId;
    if (name != null) map['name'] = name;
    if (email != null) map['email'] = email;
    if (userName != null) map['userName'] = userName;
    if (role != null) map['role'] = role.name;
    if (userType != null) map['userType'] = userType; // New field
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (dailyWage != null) map['dailyWage'] = dailyWage;
    if (storeId != null) map['storeId'] = storeId;
    if (accountLedgerId != null) map['accountLedgerId'] = accountLedgerId;
    return map;
  }

  UserInfoDto copyWith({
    String? userId,
    String? companyId,
    String? name,
    String? email,
    String? userName,
    Role? role,
    UserType? userType, // New field
    double? latitude,
    double? longitude,
    double? dailyWage,
    String? storeId,
    String? accountLedgerId,
  }) {
    return UserInfoDto(
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      userType: userType ?? this.userType,
      // New field
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dailyWage: dailyWage ?? this.dailyWage,
      storeId: storeId ?? this.storeId,
      accountLedgerId: accountLedgerId ?? this.accountLedgerId,
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
        userType, // New field
        latitude,
        longitude,
        dailyWage,
        storeId,
        accountLedgerId,
      ];
}
