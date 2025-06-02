import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaxiType extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final String createdBy;

  const TaxiType({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdBy,
  });

  factory TaxiType.fromDto(TaxiTypeDto dto) {
    return TaxiType(
      id: dto.id,
      name: dto.name,
      createdAt: dto.createdAt,
      createdBy: dto.createdBy,
    );
  }

  TaxiType copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return TaxiType(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object> get props => [id, name, createdAt, createdBy];
}
class TaxiTypeDto {
  final String id;
  final String name;
  final DateTime createdAt;
  final String createdBy;

  TaxiTypeDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdBy,
  });

  factory TaxiTypeDto.fromFirestore(QueryDocumentSnapshot doc,Map<String, dynamic> data) {
    return TaxiTypeDto(
      id:doc.id,
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

  factory TaxiTypeDto.fromModel(TaxiType model) {
    return TaxiTypeDto(
      id: model.id,
      name: model.name,
      createdAt: model.createdAt,
      createdBy: model.createdBy,
    );
  }
}
