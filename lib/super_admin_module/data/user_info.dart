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
  final String? fcmToken;
  final String? mobileNumber; // Added mobile number field

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
    this.fcmToken,
    this.mobileNumber,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'] as String?,
      companyId: json['companyId'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      userName: json['userName'] as String?,
      role: json['role'] != null ? RoleExtension.fromString(json['role']) : null,
      userType: json['userType'] != null
          ? UserTypeExtension.fromString(json['userType'])
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      dailyWage: (json['dailyWage'] as num?)?.toDouble() ?? 500.0,
      storeId: json['storeId'] as String?,
      accountLedgerId: json['accountLedgerId'] as String?,
      fcmToken: json['fcmToken'] as String?,
      mobileNumber: json['mobileNumber'] as String?, // Added to fromJson
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
      'fcmToken': fcmToken,
      'mobileNumber': mobileNumber, // Added to toJson
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
    String? fcmToken,
    String? mobileNumber,
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
      fcmToken: fcmToken ?? this.fcmToken,
      mobileNumber: mobileNumber ?? this.mobileNumber, // Added to copyWith
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
      userType: userType ?? UserType.Employee,
      latitude: latitude,
      longitude: longitude,
      dailyWage: dailyWage,
      storeId: storeId,
      accountLedgerId: accountLedgerId,
      fcmToken: fcmToken,
      mobileNumber: mobileNumber, // Added to toDto
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
      fcmToken: dto.fcmToken,
      mobileNumber: dto.mobileNumber, // Added to fromDto
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
    fcmToken,
    mobileNumber, // Added to props
  ];
}