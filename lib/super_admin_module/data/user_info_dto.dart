import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

class UserInfoDto extends Equatable {
  final String? userId; // Made optional
  final String? companyId;
  final String? name; // Made optional
  final String? email; // Made optional
  final String? userName; // Made optional
  final Role role;
  final UserType? userType;
  final double? latitude;
  final double? longitude;
  final double? dailyWage;
  final String? storeId;
  final String? accountLedgerId;
  final String? mobileNumber;
  final String? businessName;
  final String? address;

  const UserInfoDto({
    this.userId,
    this.companyId,
    this.name,
    this.email,
    this.userName,
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
      userId: map['userId'] as String? ?? '', // Default to empty string
      companyId: map['companyId'] as String?,
      name: map['name'] as String? ?? '', // Default to empty string
      email: map['email'] as String? ?? '', // Default to empty string
      userName: map['userName'] as String? ?? '', // Default to empty string
      role: RoleExtension.fromString(map['role'] as String? ?? 'user'), // Default to 'user'
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
      if (userId != null) 'userId': userId,
      if (companyId != null) 'companyId': companyId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (userName != null) 'userName': userName,
      'role': role.name,
      if (userType != null) 'userType': userType!.name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (dailyWage != null) 'dailyWage': dailyWage,
      if (storeId != null) 'storeId': storeId,
      if (accountLedgerId != null) 'accountLedgerId': accountLedgerId,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (businessName != null) 'businessName': businessName,
      if (address != null) 'address': address,
    };
  }

  Map<String, dynamic> toPartialMap() {
    final map = <String, dynamic>{};
    if (userId != null && userId!.isNotEmpty) map['userId'] = userId;
    if (companyId != null) map['companyId'] = companyId;
    if (name != null && name!.isNotEmpty) map['name'] = name;
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (userName != null && userName!.isNotEmpty) map['userName'] = userName;
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