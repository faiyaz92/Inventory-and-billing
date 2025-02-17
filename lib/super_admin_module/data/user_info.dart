import 'dart:convert';

import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';

class UserInfo {
  final String? userId;
  final String? email;
  final Role? role;
  final String? companyId;
  final String? name;
  final String? userName;

  UserInfo({
    this.userId,
    this.email,
    this.role,
    this.companyId,
    this.name,
    this.userName,
  });

  /// 🔹 Convert DTO to UI Model
  factory UserInfo.fromDto(UserInfoDto dto) {
    return UserInfo(
      userId: dto.userId,
      email: dto.email,
      role: dto.role,
      companyId: dto.companyId,
      name: dto.name,
      userName: dto.userName,
    );
  }

  /// 🔹 Convert UI Model to DTO
  UserInfoDto toDto() {
    return UserInfoDto(
      userId: userId,
      email: email,
      role: role,
      companyId: companyId,
      name: name,
      userName: userName,
    );
  }

  /// 🔹 Convert UI Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'role': role?.name, // ✅ Prevents null crash
      'companyId': companyId,
      'name': name,
      'userName': userName,
    };
  }

  /// 🔹 Create UI Model from JSON
  factory UserInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserInfo(); // ✅ Prevent null crashes

    return UserInfo(
      userId: json['userId'],
      email: json['email'],
      role: json['role'] != null ? RoleExtension.fromString(json['role']) : null, // ✅ Handles missing role safely
      companyId: json['companyId'],
      name: json['name'],
      userName: json['userName'],
    );
  }
}
