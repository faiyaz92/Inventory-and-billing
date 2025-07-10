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
  final UserType? userType;
  final double? latitude;
  final double? longitude;
  final double? dailyWage;
  final String? storeId;
  final String? accountLedgerId;
  final String? mobileNumber; // New field
  final String? businessName; // New field
  final String? address; // New field

  const UserInfoDto({
    required this.userId,
    this.companyId,
    required this.name,
    required this.email,
    required this.userName,
    required this.role,
    this.userType,
    this.latitude,
    this.longitude,
    this.dailyWage,
    this.storeId,
    this.accountLedgerId,
    this.mobileNumber,
    this.businessName,
    this.address,
  });

  factory UserInfoDto.fromMap(Map<String, dynamic> map) {
    final userTypeRaw = map['userType'] as String?;
    final userType = UserTypeExtension.fromString(userTypeRaw) ?? UserType.Customer;
    if (userTypeRaw != null && userType == UserType.Customer) {
      print('UserInfoDto.fromMap: Defaulted userType to Customer for raw value "$userTypeRaw"');
    }
    return UserInfoDto(
      userId: map['userId'] as String,
      companyId: map['companyId'] as String?,
      name: map['name'] as String,
      email: map['email'] as String,
      userName: map['userName'] as String,
      role: RoleExtension.fromString(map['role'] as String),
      userType: userType,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      dailyWage: (map['dailyWage'] as num?)?.toDouble() ?? 500.0,
      storeId: map['storeId'] as String?,
      accountLedgerId: map['accountLedgerId'] as String?,
      mobileNumber: map['mobileNumber'] as String?,
      businessName: map['businessName'] as String?,
      address: map['address'] as String?,
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
      'userType': userType?.name,
      'latitude': latitude,
      'longitude': longitude,
      'dailyWage': dailyWage,
      'storeId': storeId,
      'accountLedgerId': accountLedgerId,
      'mobileNumber': mobileNumber,
      'businessName': businessName,
      'address': address,
    };
  }

  Map<String, dynamic> toPartialMap() {
    final map = <String, dynamic>{};
    map['userId'] = userId;
    if (companyId != null) map['companyId'] = companyId;
    if (name.isNotEmpty) map['name'] = name;
    if (email.isNotEmpty) map['email'] = email;
    if (userName.isNotEmpty) map['userName'] = userName;
    map['role'] = role.name;
    if (userType != null) map['userType'] = userType!.name;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (dailyWage != null) map['dailyWage'] = dailyWage;
    if (storeId != null) map['storeId'] = storeId;
    if (accountLedgerId != null) map['accountLedgerId'] = accountLedgerId;
    if (mobileNumber != null) map['mobileNumber'] = mobileNumber;
    if (businessName != null) map['businessName'] = businessName;
    if (address != null) map['address'] = address;
    return map;
  }

  UserInfoDto copyWith({
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
  }) {
    return UserInfoDto(
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
  ];
}