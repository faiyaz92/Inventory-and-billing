import 'package:cloud_firestore/cloud_firestore.dart';

class CompanySettingsUi {
  final List<String> sources;
  final List<String> priorities;
  final List<String> verifiedOn;
  final Map<String, List<String>> countryCityMap;
  final List<String> businessTypes;
  final List<String> taskStatuses;
  final Map<String, List<String>> purposeTypeMap; // New: Purpose -> Types mapping

  CompanySettingsUi({
    required this.sources,
    required this.priorities,
    required this.verifiedOn,
    required this.countryCityMap,
    required this.businessTypes,
    required this.taskStatuses,
    required this.purposeTypeMap,
  });

  factory CompanySettingsUi.initial() {
    return CompanySettingsUi(
      sources: [],
      priorities: [],
      verifiedOn: [],
      countryCityMap: {},
      businessTypes: [],
      taskStatuses: [],
      purposeTypeMap: {'Material': [], 'Labor': []}, // Default purposes
    );
  }

  CompanySettingsUi copyWith({
    List<String>? sources,
    List<String>? priorities,
    List<String>? verifiedOn,
    Map<String, List<String>>? countryCityMap,
    List<String>? businessTypes,
    List<String>? taskStatuses,
    Map<String, List<String>>? purposeTypeMap,
  }) {
    return CompanySettingsUi(
      sources: sources ?? this.sources,
      priorities: priorities ?? this.priorities,
      verifiedOn: verifiedOn ?? this.verifiedOn,
      countryCityMap: countryCityMap ?? this.countryCityMap,
      businessTypes: businessTypes ?? this.businessTypes,
      taskStatuses: taskStatuses ?? this.taskStatuses,
      purposeTypeMap: purposeTypeMap ?? this.purposeTypeMap,
    );
  }

  factory CompanySettingsUi.fromMap(Map<String, dynamic> map) {
    return CompanySettingsUi(
      sources: List<String>.from(map['sources'] ?? []),
      priorities: List<String>.from(map['priorities'] ?? []),
      verifiedOn: List<String>.from(map['verifiedOn'] ?? []),
      countryCityMap: Map<String, List<String>>.from(
        (map['countryCityMap'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
        ) ??
            {},
      ),
      businessTypes: List<String>.from(map['businessTypes'] ?? []),
      taskStatuses: List<String>.from(map['taskStatuses'] ?? []),
      purposeTypeMap: Map<String, List<String>>.from(
        (map['purposeTypeMap'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
        ) ??
            {'Material': [], 'Labor': []},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sources': sources,
      'priorities': priorities,
      'verifiedOn': verifiedOn,
      'countryCityMap': countryCityMap,
      'businessTypes': businessTypes,
      'taskStatuses': taskStatuses,
      'purposeTypeMap': purposeTypeMap,
    };
  }
}