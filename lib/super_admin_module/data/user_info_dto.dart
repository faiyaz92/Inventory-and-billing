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
    };
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