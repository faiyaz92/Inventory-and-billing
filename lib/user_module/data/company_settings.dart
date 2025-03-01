class CompanySettingsUi {
  final List<String> sources;
  final List<String> priorities;
  final List<String> verifiedOn;
  final Map<String, List<String>> countryCityMap;
  final List<String> businessTypes;
  final List<String> taskStatuses;

  CompanySettingsUi({
    required this.sources,
    required this.priorities,
    required this.verifiedOn,
    required this.countryCityMap,
    required this.businessTypes,
    required this.taskStatuses,
  });

  factory CompanySettingsUi.initial() {
    return CompanySettingsUi(
      sources: [],
      priorities: [],
      verifiedOn: [],
      countryCityMap: {},
      businessTypes: [],
      taskStatuses: [],
    );
  }

  CompanySettingsUi copyWith({
    List<String>? sources,
    List<String>? priorities,
    List<String>? verifiedOn,
    Map<String, List<String>>? countryCityMap,
    List<String>? businessTypes,
    List<String>? taskStatuses,
  }) {
    return CompanySettingsUi(
      sources: sources ?? this.sources,
      priorities: priorities ?? this.priorities,
      verifiedOn: verifiedOn ?? this.verifiedOn,
      countryCityMap: countryCityMap ?? this.countryCityMap,
      businessTypes: businessTypes ?? this.businessTypes,
      taskStatuses: taskStatuses ?? this.taskStatuses,
    );
  }
}
