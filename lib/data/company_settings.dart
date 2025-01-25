class CompanySettingsUi {
  final List<String> sources;
  final List<String> priorities;
  final List<String> verifiedOn;
  final Map<String, List<String>> countryCityMap; // Country -> Cities Map

  CompanySettingsUi({
    required this.sources,
    required this.priorities,
    required this.verifiedOn,
    required this.countryCityMap,
  });


  factory CompanySettingsUi.initial() {
    return CompanySettingsUi(
      sources: [],
      priorities: [],
      verifiedOn: [],
      countryCityMap: {

      },
    );
  }

  CompanySettingsUi copyWith({
    List<String>? sources,
    List<String>? priorities,
    List<String>? verifiedOn,
    Map<String, List<String>>? countryCityMap,
  }) {
    return CompanySettingsUi(
      sources: sources ?? this.sources,
      priorities: priorities ?? this.priorities,
      verifiedOn: verifiedOn ?? this.verifiedOn,
      countryCityMap: countryCityMap ?? this.countryCityMap,
    );
  }
}
