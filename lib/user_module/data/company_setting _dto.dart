import 'package:requirment_gathering_app/user_module/data/company_settings.dart';

class CompanySettingDto {
  final List<String> sources;
  final List<String> priorities;
  final List<String> verifiedOn;
  final Map<String, List<String>> countryCityMap;
  final List<String> businessTypes;
  final List<String> taskStatuses;
  final Map<String, List<String>> purposeTypeMap; // New: Purpose -> Types mapping

  CompanySettingDto({
    required this.sources,
    required this.priorities,
    required this.verifiedOn,
    required this.countryCityMap,
    required this.businessTypes,
    required this.taskStatuses,
    required this.purposeTypeMap,
  });

  factory CompanySettingDto.fromMap(Map<String, dynamic> map) {
    return CompanySettingDto(
      sources: List<String>.from(map['sources'] ?? []),
      priorities: List<String>.from(map['priorities'] ?? []),
      verifiedOn: List<String>.from(map['verifiedOn'] ?? []),
      countryCityMap: (map['countryCityMap'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
      ) ?? {},
      businessTypes: List<String>.from(map['businessTypes'] ?? []),
      taskStatuses: List<String>.from(map['taskStatuses'] ?? []),
      purposeTypeMap: (map['purposeTypeMap'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
      ) ?? {'Material': [], 'Labor': []},
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

  CompanySettingsUi toUiModel() {
    return CompanySettingsUi(
      sources: sources,
      priorities: priorities,
      verifiedOn: verifiedOn,
      countryCityMap: countryCityMap,
      businessTypes: businessTypes,
      taskStatuses: taskStatuses,
      purposeTypeMap: purposeTypeMap,
    );
  }

  factory CompanySettingDto.fromUiModel(CompanySettingsUi uiModel) {
    return CompanySettingDto(
      sources: uiModel.sources,
      priorities: uiModel.priorities,
      verifiedOn: uiModel.verifiedOn,
      countryCityMap: uiModel.countryCityMap,
      businessTypes: uiModel.businessTypes,
      taskStatuses: uiModel.taskStatuses,
      purposeTypeMap: uiModel.purposeTypeMap,
    );
  }
}