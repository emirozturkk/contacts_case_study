import 'dart:developer';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// this interface is used to control contacts on the device
class ContactsController extends Notifier<List<Contact>> {
  @override
  List<Contact> build() {
    return [];
  }

  // Request permission and load contacts
  Future<void> requestPermissionAndLoadContacts() async {
    // Request permission
    if (await FlutterContacts.requestPermission()) {
      // Permission granted, load contacts
      await _loadContacts();
    } else {
      // Permission denied
      log('Permission denied');
    }
  }

  // Load all contacts
  Future<void> _loadContacts() async {
    try {
      // Get all contacts with their properties
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      state = contacts;
    } catch (e) {
      log('Error loading contacts: $e');
    }
  }

  // Create a new contact
  Future<void> createContact({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    final newContact = Contact()
      ..name.first = firstName
      ..name.last = lastName
      ..phones = [Phone(phoneNumber, label: PhoneLabel.mobile)];

    try {
      await newContact.insert();
      await _loadContacts(); // Reload contacts
    } catch (e) {
      throw Exception(e);
    }
  }

  // // Update an existing contact
  // Future<void> updateContact({
  //   required Contact contact,
  //   required String firstName,
  //   required String lastName,
  //   required String phoneNumber,
  // }) async {
  //   try {
  //     // Modify the contact
  //     contact.name.first = firstName;
  //     contact.name.last = lastName;
  //     contact.phones = [Phone(phoneNumber, label: PhoneLabel.mobile)];

  //     // Update in device
  //     await contact.update();
  //     await _loadContacts(); // Reload contacts
  //   } catch (e) {
  //     log('Error updating contact: $e');
  //   }
  // }

  // // Delete a contact
  // Future<void> deleteContact({required Contact contact}) async {
  //   try {
  //     await contact.delete();
  //     await _loadContacts(); // Reload contacts
  //   } catch (e) {
  //     log('Error deleting contact: $e');
  //   }
  // }
}

// this provider is used to control contacts on the device
final contactsControllerProvider =
    NotifierProvider<ContactsController, List<Contact>>(
      () => ContactsController(),
    );
