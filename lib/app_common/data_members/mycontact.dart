import 'package:flutter_contacts/flutter_contacts.dart';

class MyContact {
  Contact? contact;
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String profileImageUrl;

  MyContact({
    required this.contact,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.profileImageUrl,
  });

  MyContact copyWith({
    Contact? contact,
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) {
    return MyContact(
      contact: contact ?? this.contact,
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  factory MyContact.fromJson(Map<String, dynamic> json) {
    return MyContact(
      contact: json['contact'] != null
          ? Contact.fromJson(json['contact'])
          : null,
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
}
