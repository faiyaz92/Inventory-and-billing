import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TripStatus extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final String createdBy;

  const TripStatus({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdBy,
  });

  factory TripStatus.fromDto(TripStatusDto dto) {
    return TripStatus(
      id: dto.id,
      name: dto.name,
      createdAt: dto.createdAt,
      createdBy: dto.createdBy,
    );
  }

  TripStatus copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return TripStatus(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object> get props => [id, name, createdAt, createdBy];
}
class TripStatusDto {
  final String id;
  final String name;
  final DateTime createdAt;
  final String createdBy;

  TripStatusDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdBy,
  });

  factory TripStatusDto.fromFirestore(QueryDocumentSnapshot data) {
    return TripStatusDto(
      id: data.id,
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

  factory TripStatusDto.fromModel(TripStatus model) {
    return TripStatusDto(
      id: model.id,
      name: model.name,
      createdAt: model.createdAt,
      createdBy: model.createdBy,
    );
  }
}