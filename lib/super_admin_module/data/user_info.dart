import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';

class UserInfo extends Equatable {
  final String? userId;
  final String? companyId;
  final String? name;
  final String? email;
  final String? userName;
  final Role? role;
  final double? latitude;
  final double? longitude;
  final double? dailyWage;

  const UserInfo({
    this.userId,
    this.companyId,
    this.name,
    this.email,
    this.userName,
    this.role,
    this.latitude,
    this.longitude,
    this.dailyWage,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'] as String?,
      companyId: json['companyId'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      userName: json['userName'] as String?,
      role: json['role'] != null ? RoleExtension.fromString(json['role']) : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      dailyWage: (json['dailyWage'] as num?)?.toDouble() ?? 500.0,
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
      'latitude': latitude,
      'longitude': longitude,
      'dailyWage': dailyWage,
    };
  }

  UserInfo copyWith({
    String? userId,
    String? companyId,
    String? name,
    String? email,
    String? userName,
    Role? role,
    double? latitude,
    double? longitude,
    double? dailyWage,
  }) {
    return UserInfo(
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dailyWage: dailyWage ?? this.dailyWage,
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
      latitude: latitude,
      longitude: longitude,
      dailyWage: dailyWage,
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
      latitude: dto.latitude,
      longitude: dto.longitude,
      dailyWage: dto.dailyWage,
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
  ];
}