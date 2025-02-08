class AiCompanyDto {
  final String companyName;
  final String country;
  final String city;
  final String businessType;
  final String? website;

  AiCompanyDto({
    required this.companyName,
    required this.country,
    required this.city,
    required this.businessType,
    this.website,
  });

  factory AiCompanyDto.fromMap(Map<String, dynamic> map) {
    return AiCompanyDto(
      companyName: map['companyName'],
      country: map['country'],
      city: map['city'],
      businessType: map['businessType'],
      website: map['website'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'country': country,
      'city': city,
      'businessType': businessType,
      'website': website,
    };
  }
}
