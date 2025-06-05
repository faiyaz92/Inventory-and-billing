import 'package:cloud_firestore/cloud_firestore.dart';

class VisitorCounter {
  final int count;
  final DateTime lastUpdated;
  final String page;

  VisitorCounter({
    required this.count,
    required this.lastUpdated,
    required this.page,
  });

  factory VisitorCounter.fromDto(VisitorCounterDto dto) {
    return VisitorCounter(
      count: dto.count,
      lastUpdated: dto.lastUpdated,
      page: dto.page,
    );
  }
}

class VisitorCounterDto {
  final int count;
  final DateTime lastUpdated;
  final String page;

  VisitorCounterDto({
    required this.count,
    required this.lastUpdated,
    required this.page,
  });

  factory VisitorCounterDto.fromFirestore(Map<String, dynamic> data) {
    return VisitorCounterDto(
      count: data['count'] ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      page: data['page'] ?? 'TaxiBookingPage',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'count': count,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'page': page,
    };
  }
}
