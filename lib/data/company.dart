  import 'package:requirment_gathering_app/data/company_settings.dart';

  class Company {
    final String id;
    final String companyName;
    final String? source;
    final String? address;
    final String? email;
    final String? contactNumber;
    final List<ContactPerson> contactPersons;
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
    final String? description; // Added back
    final CompanySettingsUi? settings; // Embed CompanySettingsUi
    final String createdBy; // Retained
    final String lastUpdatedBy; // Retained

    Company({
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
      this.websiteLink,
      this.linkedInLink,
      this.clutchLink,
      this.goodFirmLink,
      this.description, // Added back
      this.verifiedOn = const [],
      required this.dateCreated,
      this.settings,
      required this.createdBy, // Retained
      required this.lastUpdatedBy, // Retained
    });

    Company copyWith({
      String? id,
      String? companyName,
      String? source,
      String? address,
      String? email,
      String? contactNumber,
      List<ContactPerson>? contactPersons,
      bool? emailSent,
      bool? theyReplied,
      String? interestLevel,
      String? country,
      String? city,
      String? priority,
      String? assignedTo,
      List<String>? verifiedOn,
      DateTime? dateCreated,
      String? websiteLink,
      String? linkedInLink,
      String? clutchLink,
      String? goodFirmLink,
      String? description, // Added back
      CompanySettingsUi? settings,
      String? createdBy, // Retained
      String? lastUpdatedBy, // Retained
    }) {
      return Company(
        id: id ?? this.id,
        companyName: companyName ?? this.companyName,
        source: source ?? this.source,
        address: address ?? this.address,
        email: email ?? this.email,
        contactNumber: contactNumber ?? this.contactNumber,
        contactPersons: contactPersons ?? this.contactPersons,
        emailSent: emailSent ?? this.emailSent,
        theyReplied: theyReplied ?? this.theyReplied,
        interestLevel: interestLevel ?? this.interestLevel,
        country: country ?? this.country,
        city: city /*?? this.city*/,
        priority: priority ?? this.priority,
        assignedTo: assignedTo ?? this.assignedTo,
        verifiedOn: verifiedOn ?? this.verifiedOn,
        dateCreated: dateCreated ?? this.dateCreated,
        websiteLink: websiteLink ?? this.websiteLink,
        linkedInLink: linkedInLink ?? this.linkedInLink,
        clutchLink: clutchLink ?? this.clutchLink,
        goodFirmLink: goodFirmLink ?? this.goodFirmLink,
        description: description ?? this.description, // Added back
        settings: settings ?? this.settings,
        createdBy: createdBy ?? this.createdBy, // Retained
        lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy, // Retained
      );
    }
  }

  class ContactPerson {
    final String name;
    final String email;
    final String phoneNumber;

    ContactPerson({
      required this.name,
      required this.email,
      required this.phoneNumber,
    });

    factory ContactPerson.fromMap(Map<String, dynamic> map) {
      return ContactPerson(
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

    ContactPerson copyWith({
      String? name,
      String? email,
      String? phoneNumber,
    }) {
      return ContactPerson(
        name: name ?? this.name,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );
    }
  }
