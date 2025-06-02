import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TripType extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final String createdBy;

  const TripType({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdBy,
  });

  factory TripType.fromDto(TripTypeDto dto) {
    return TripType(
      id: dto.id,
      name: dto.name,
      createdAt: dto.createdAt,
      createdBy: dto.createdBy,
    );
  }

  TripType copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return TripType(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object> get props => [id, name, createdAt, createdBy];
}
class TripTypeDto {
  final String id;
  final String name;
  final DateTime createdAt;
  final String createdBy;

  TripTypeDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdBy,
  });

  factory TripTypeDto.fromFirestore(Map<String, dynamic> data) {
    return TripTypeDto(
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

  factory TripTypeDto.fromModel(TripType model) {
    return TripTypeDto(
      id: model.id,
      name: model.name,
      createdAt: model.createdAt,
      createdBy: model.createdBy,
    );
  }
}