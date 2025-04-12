
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';

class UserInfoDto {
  final String? userId;
  final String? email;
  final Role? role;
  final String? companyId;
  final String? name;
  final String? userName;

  UserInfoDto({
    this.userId,
    this.email,
    this.role,
    this.companyId,
    this.name,
    this.userName,
  });

  /// 🔹 Convert Firestore data to UserInfoDto
  factory UserInfoDto.fromMap(Map<String, dynamic>? map) {
    if (map == null) return UserInfoDto(); // ✅ Prevent null crashes

    return UserInfoDto(
      userId: map['userId'],
      email: map['email'],
      role: map['role'] != null ? RoleExtension.fromString(map['role']) : null, // ✅ Handles missing role safely
      companyId: map['companyId'],
      name: map['name'],
      userName: map['userName'],
    );
  }

  /// 🔹 Convert DTO to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'role': role?.name, // ✅ Avoids null role issues
      'companyId': companyId,
      'name': name,
      'userName': userName,
    };
  }

  /// 🔹 Create a copy with modifications
  UserInfoDto copyWith({
    String? userId,
    String? email,
    Role? role,
    String? companyId,
    String? name,
    String? userName,
  }) {
    return UserInfoDto(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      userName: userName ?? this.userName,
    );
  }
}
