import 'package:requirment_gathering_app/user_module/data/partner.dart';

class PartnerDto {
  final String id;
  final String? companyType; // Added
  final String companyName;
  final String? source;
  final String? address;
  final String? email;
  final String? contactNumber;
  final List<ContactPersonDto> contactPersons;
  final bool emailSent;
  final bool theyReplied;
  final String? interestLevel;
  final String? country;
  final String? city;
  final String? priority;
  final String? assignedTo;
  final List<String> verifiedOn;
  final DateTime dateCreated;
  final String? websiteLink;
  final String? linkedInLink;
  final String? clutchLink;
  final String? goodFirmLink;
  final String? description;
  final String? businessType;
  final String createdBy;
  final String lastUpdatedBy;
  final String? accountLedgerId;

  PartnerDto({
    required this.id,
    this.companyType,
    required this.companyName,
    this.source,
    this.address,
    this.email,
    this.contactNumber,
    this.contactPersons = const [],
    this.emailSent = false,
    this.theyReplied = false,
    this.interestLevel,
    this.country,
    this.city,
    this.priority,
    this.assignedTo,
    this.verifiedOn = const [],
    required this.dateCreated,
    this.websiteLink,
    this.linkedInLink,
    this.clutchLink,
    this.goodFirmLink,
    this.description,
    this.businessType,
    required this.createdBy,
    required this.lastUpdatedBy,
    this.accountLedgerId,
  });

  factory PartnerDto.fromMap(Map<String, dynamic> map, String id) {
    return PartnerDto(
      id: id,
      companyType: map['companyType'],
      companyName: map['companyName'] ?? '',
      source: map['source'],
      address: map['address'],
      email: map['email'],
      contactNumber: map['contactNumber'],
      contactPersons: (map['contactPersons'] as List<dynamic>? ?? [])
          .map((e) => ContactPersonDto.fromMap(e))
          .toList(),
      emailSent: map['emailSent'] ?? false,
      theyReplied: map['theyReplied'] ?? false,
      interestLevel: map['interestLevel'],
      country: map['country'],
      city: map['city'],
      priority: map['priority'],
      assignedTo: map['assignedTo'],
      verifiedOn: List<String>.from(map['verifiedOn'] ?? []),
      dateCreated: DateTime.parse(map['dateCreated']),
      websiteLink: map['websiteLink'] ?? '',
      linkedInLink: map['linkedInLink'] ?? '',
      clutchLink: map['clutchLink'] ?? '',
      goodFirmLink: map['goodFirmLink'] ?? '',
      description: map['description'],
      businessType: map['businessType'],
      createdBy: map['createdBy'] ?? 'Unknown',
      lastUpdatedBy: map['lastUpdatedBy'] ?? 'Unknown',
      accountLedgerId: map['accountLedgerId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyType': companyType,
      'companyName': companyName,
      'source': source,
      'address': address,
      'email': email,
      'contactNumber': contactNumber,
      'contactPersons': contactPersons.map((e) => e.toMap()).toList(),
      'emailSent': emailSent,
      'theyReplied': theyReplied,
      'interestLevel': interestLevel,
      'country': country,
      'city': city,
      'priority': priority,
      'assignedTo': assignedTo,
      'verifiedOn': verifiedOn,
      'dateCreated': dateCreated.toIso8601String(),
      'websiteLink': websiteLink,
      'linkedInLink': linkedInLink,
      'clutchLink': clutchLink,
      'goodFirmLink': goodFirmLink,
      'description': description,
      'businessType': businessType,
      'createdBy': createdBy,
      'lastUpdatedBy': lastUpdatedBy,
      'accountLedgerId': accountLedgerId,
    };
  }

  Partner toUiModel() {
    return Partner(
      id: id,
      companyType: companyType,
      companyName: companyName,
      source: source,
      address: address,
      email: email,
      contactNumber: contactNumber,
      contactPersons: contactPersons.map((e) => e.toUiModel()).toList(),
      emailSent: emailSent,
      theyReplied: theyReplied,
      interestLevel: interestLevel,
      country: country,
      city: city,
      priority: priority,
      assignedTo: assignedTo,
      verifiedOn: verifiedOn,
      dateCreated: dateCreated,
      websiteLink: websiteLink,
      linkedInLink: linkedInLink,
      clutchLink: clutchLink,
      goodFirmLink: goodFirmLink,
      description: description,
      businessType: businessType,
      createdBy: createdBy,
      lastUpdatedBy: lastUpdatedBy,
      accountLedgerId: accountLedgerId,
    );
  }

  factory PartnerDto.fromUiModel(Partner uiModel) {
    return PartnerDto(
      id: uiModel.id,
      companyType: uiModel.companyType,
      companyName: uiModel.companyName,
      source: uiModel.source,
      address: uiModel.address,
      email: uiModel.email,
      contactNumber: uiModel.contactNumber,
      contactPersons: uiModel.contactPersons
          .map((e) => ContactPersonDto.fromUiModel(e))
          .toList(),
      emailSent: uiModel.emailSent,
      theyReplied: uiModel.theyReplied,
      interestLevel: uiModel.interestLevel,
      country: uiModel.country,
      city: uiModel.city,
      priority: uiModel.priority,
      assignedTo: uiModel.assignedTo,
      verifiedOn: uiModel.verifiedOn,
      dateCreated: uiModel.dateCreated,
      websiteLink: uiModel.websiteLink,
      linkedInLink: uiModel.linkedInLink,
      clutchLink: uiModel.clutchLink,
      goodFirmLink: uiModel.goodFirmLink,
      description: uiModel.description,
      businessType: uiModel.businessType,
      createdBy: uiModel.createdBy,
      lastUpdatedBy: uiModel.lastUpdatedBy,
      accountLedgerId: uiModel.accountLedgerId,
    );
  }
}

class ContactPersonDto {
  final String name;
  final String email;
  final String phoneNumber;

  ContactPersonDto({
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory ContactPersonDto.fromMap(Map<String, dynamic> map) {
    return ContactPersonDto(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  ContactPerson toUiModel() {
    return ContactPerson(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
    );
  }

  factory ContactPersonDto.fromUiModel(ContactPerson uiModel) {
    return ContactPersonDto(
      name: uiModel.name,
      email: uiModel.email,
      phoneNumber: uiModel.phoneNumber,
    );
  }
}