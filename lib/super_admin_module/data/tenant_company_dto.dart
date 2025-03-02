import 'package:cloud_firestore/cloud_firestore.dart';

class TenantCompanyDto {
  final String? companyId;
  final String? name;
  final String? email;
  final String? mobileNumber;
  final String? gstin;
  final String? country;
  final String? state;
  final String? city;
  final String? zipCode;
  final String? address;
  final String? createdBy;
  final Timestamp? createdAt;

  TenantCompanyDto({
    this.companyId,
    this.name,
    this.email,
    this.mobileNumber,
    this.gstin,
    this.country,
    this.state,
    this.city,
    this.zipCode,
    this.address,
    this.createdBy,
    this.createdAt,
  });

  /// 🔹 Convert DTO to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'companyId': companyId,
      'name': name,
      'email': email,
      'mobileNumber': mobileNumber,
      'gstin': gstin,
      'country': country,
      'state': state,
      'city': city,
      'zipCode': zipCode,
      'address': address,
      'createdBy': createdBy,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// 🔹 Convert Firestore Document to DTO
  factory TenantCompanyDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return TenantCompanyDto(
      companyId: data['companyId'] ?? doc.id,
      name: data['name'],
      email: data['email'],
      mobileNumber: data['mobileNumber'],
      gstin: data['gstin'],
      country: data['country'],
      state: data['state'],
      city: data['city'],
      zipCode: data['zipCode'],
      address: data['address'],
      createdBy: data['createdBy'],
      createdAt: data['createdAt'] != null ? data['createdAt'] as Timestamp : null,
    );
  }

  /// 🔹 Convert JSON Map to DTO
  factory TenantCompanyDto.fromMap(Map<String, dynamic>? map) {
    if (map == null) return TenantCompanyDto();

    return TenantCompanyDto(
      companyId: map['companyId'],
      name: map['name'],
      email: map['email'],
      mobileNumber: map['mobileNumber'],
      gstin: map['gstin'],
      country: map['country'],
      state: map['state'],
      city: map['city'],
      zipCode: map['zipCode'],
      address: map['address'],
      createdBy: map['createdBy'],
      createdAt: map['createdAt'] != null ? map['createdAt'] as Timestamp : null,
    );
  }

  /// 🔹 Create a copy with modifications
  TenantCompanyDto copyWith({
    String? companyId,
    String? name,
    String? email,
    String? mobileNumber,
    String? gstin,
    String? country,
    String? state,
    String? city,
    String? zipCode,
    String? address,
    String? createdBy,
    Timestamp? createdAt,
  }) {
    return TenantCompanyDto(
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      gstin: gstin ?? this.gstin,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      address: address ?? this.address,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 🔹 Convert DTO to Firestore Map (Use this for updates)
  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'name': name,
      'email': email,
      'mobileNumber': mobileNumber,
      'gstin': gstin,
      'country': country,
      'state': state,
      'city': city,
      'zipCode': zipCode,
      'address': address,
      'createdBy': createdBy,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
