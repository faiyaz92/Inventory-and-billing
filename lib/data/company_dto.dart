import 'package:requirment_gathering_app/data/company.dart';

class CompanyDto {
  final String id;
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
  final String? description; // New field
  final String createdBy; // New field
  final String lastUpdatedBy; // New field

  CompanyDto({
    required this.id,
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
    required this.createdBy,
    required this.lastUpdatedBy,
  });

  // Map from Firebase data to DTO
  factory CompanyDto.fromMap(Map<String, dynamic> map, String id) {
    return CompanyDto(
      id: id,
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
      createdBy: map['createdBy'] ?? 'Unknown',
      lastUpdatedBy: map['lastUpdatedBy'] ?? 'Unknown',
    );
  }

  // Map to Firebase data
  Map<String, dynamic> toMap() {
    return {
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
      'createdBy': createdBy,
      'lastUpdatedBy': lastUpdatedBy,
    };
  }

  // Convert from DTO to UI Model
  Company toUiModel() {
    return Company(
      id: id,
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
      createdBy: createdBy,
      lastUpdatedBy: lastUpdatedBy,
    );
  }

  // Convert from UI Model to DTO
  factory CompanyDto.fromUiModel(Company uiModel) {
    return CompanyDto(
      id: uiModel.id,
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
      createdBy: uiModel.createdBy,
      lastUpdatedBy: uiModel.lastUpdatedBy,
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

  // Convert from Firebase Map to DTO
  factory ContactPersonDto.fromMap(Map<String, dynamic> map) {
    return ContactPersonDto(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }

  // Convert DTO to Firebase Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  // Convert from DTO to UI Model
  ContactPerson toUiModel() {
    return ContactPerson(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
    );
  }

  // Convert from UI Model to DTO
  factory ContactPersonDto.fromUiModel(ContactPerson uiModel) {
    return ContactPersonDto(
      name: uiModel.name,
      email: uiModel.email,
      phoneNumber: uiModel.phoneNumber,
    );
  }
}
