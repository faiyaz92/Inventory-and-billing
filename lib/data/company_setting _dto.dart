import 'package:requirment_gathering_app/data/company_settings.dart';

class CompanySettingDto {
  final List<String> sources;
  final List<String> priorities;
  final List<String> verifiedOn;
  final Map<String, List<String>> countryCityMap;

  CompanySettingDto({
    required this.sources,
    required this.priorities,
    required this.verifiedOn,
    required this.countryCityMap,
  });

  factory CompanySettingDto.fromMap(Map<String, dynamic> map) {
    return CompanySettingDto(
      sources: List<String>.from(map['sources'] ?? []),
      priorities: List<String>.from(map['priorities'] ?? []),
      verifiedOn: List<String>.from(map['verifiedOn'] ?? []),
      countryCityMap: (map['countryCityMap'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
      ) ??
          {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sources': sources,
      'priorities': priorities,
      'verifiedOn': verifiedOn,
      'countryCityMap': countryCityMap,
    };
  }

  // Map DTO to UI Model
  CompanySettingsUi toUiModel() {
    return CompanySettingsUi(
      sources: sources,
      priorities: priorities,
      verifiedOn: verifiedOn,
      countryCityMap: countryCityMap,
    );
  }

  // Map UI Model to DTO
  factory CompanySettingDto.fromUiModel(CompanySettingsUi uiModel) {
    return CompanySettingDto(
      sources: uiModel.sources,
      priorities: uiModel.priorities,
      verifiedOn: uiModel.verifiedOn,
      countryCityMap: uiModel.countryCityMap,
    );
  }
}
