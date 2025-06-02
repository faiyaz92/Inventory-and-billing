import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ServiceType extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final String createdBy;

  const ServiceType({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdBy,
  });

  factory ServiceType.fromDto(ServiceTypeDto dto) {
    return ServiceType(
      id: dto.id,
      name: dto.name,
      createdAt: dto.createdAt,
      createdBy: dto.createdBy,
    );
  }

  ServiceType copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return ServiceType(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object> get props => [id, name, createdAt, createdBy];
}
class ServiceTypeDto {
  final String id;
  final String name;
  final DateTime createdAt;
  final String createdBy;

  ServiceTypeDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdBy,
  });

  factory ServiceTypeDto.fromFirestore(Map<String, dynamic> data) {
    return ServiceTypeDto(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory ServiceTypeDto.fromModel(ServiceType model) {
    return ServiceTypeDto(
      id: model.id,
      name: model.name,
      createdAt: model.createdAt,
      createdBy: model.createdBy,
    );
  }
}