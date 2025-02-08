class CompanySettingsUi {
  final List<String> sources;
  final List<String> priorities;
  final List<String> verifiedOn;
  final Map<String, List<String>> countryCityMap; // Country -> Cities Map
  final List<String> businessTypes; // New field for Business Types

  CompanySettingsUi({
    required this.sources,
    required this.priorities,
    required this.verifiedOn,
    required this.countryCityMap,
    required this.businessTypes, // Add businessTypes to the constructor
  });

  factory CompanySettingsUi.initial() {
    return CompanySettingsUi(
      sources: [],
      priorities: [],
      verifiedOn: [],
      countryCityMap: {},
      businessTypes: [], // Initialize businessTypes as an empty list
    );
  }

  CompanySettingsUi copyWith({
    List<String>? sources,
    List<String>? priorities,
    List<String>? verifiedOn,
    Map<String, List<String>>? countryCityMap,
    List<String>? businessTypes, // Add businessTypes parameter to copyWith
  }) {
    return CompanySettingsUi(
      sources: sources ?? this.sources,
      priorities: priorities ?? this.priorities,
      verifiedOn: verifiedOn ?? this.verifiedOn,
      countryCityMap: countryCityMap ?? this.countryCityMap,
      businessTypes: businessTypes ?? this.businessTypes, // Handle businessTypes in copyWith
    );
  }
}
