import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';

class UserInfoDto extends Equatable {
  final String userId;
  final String? companyId;
  final String name;
  final String email;
  final String userName;
  final Role role;
  final double? latitude;
  final double? longitude;
  final double? dailyWage;
  final String? storeId;
  final String? accountLedgerId; // New field

  const UserInfoDto({
    required this.userId,
    this.companyId,
    required this.name,
    required this.email,
    required this.userName,
    required this.role,
    this.latitude,
    this.longitude,
    this.dailyWage,
    this.storeId,
    this.accountLedgerId, // New field
  });

  factory UserInfoDto.fromMap(Map<String, dynamic> map) {
    return UserInfoDto(
      userId: map['userId'] as String,
      companyId: map['companyId'] as String?,
      name: map['name'] as String,
      email: map['email'] as String,
      userName: map['userName'] as String,
      role: RoleExtension.fromString(map['role'] as String),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      dailyWage: (map['dailyWage'] as num?)?.toDouble() ?? 500.0,
      storeId: map['storeId'] as String?,
      accountLedgerId: map['accountLedgerId'] as String?, // New field
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
      'latitude': latitude,
      'longitude': longitude,
      'dailyWage': dailyWage,
      'storeId': storeId,
      'accountLedgerId': accountLedgerId, // New field
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
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (dailyWage != null) map['dailyWage'] = dailyWage;
    if (storeId != null) map['storeId'] = storeId;
    if (accountLedgerId != null) map['accountLedgerId'] = accountLedgerId; // New field
    return map;
  }

  UserInfoDto copyWith({
    String? userId,
    String? companyId,
    String? name,
    String? email,
    String? userName,
    Role? role,
    double? latitude,
    double? longitude,
    double? dailyWage,
    String? storeId,
    String? accountLedgerId, // New field
  }) {
    return UserInfoDto(
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dailyWage: dailyWage ?? this.dailyWage,
      storeId: storeId ?? this.storeId,
      accountLedgerId: accountLedgerId ?? this.accountLedgerId, // New field
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
    latitude,
    longitude,
    dailyWage,
    storeId,
    accountLedgerId, // New field
  ];
}