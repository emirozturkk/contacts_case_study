import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:contacts/app_common/data_members/mycontact.dart';
import 'package:contacts/providers/database/nexoft_database_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:contacts/providers/shared_preferences_interface/search_history_controller_provider.dart';
import 'package:contacts/providers/contacts_interface/device_contacts_controller_provider.dart';
import 'package:contacts/app_common/snackbar/app_snackbar.dart';
import 'package:contacts/providers/shared_preferences_interface/contacts_list_cache_interface.dart';

class HomeScreenNotifier extends Notifier<List<MyContact>> {
  @override
  List<MyContact> build() {
    return [];
  }

  void _updateCacheContactsList(List<MyContact> contacts) async {
    final contactsListCacheInterface = await ref.read(
      contactsListCacheInterfaceProvider.future,
    );

    List<Map<String, dynamic>> _contacts = contacts
        .map(
          (contact) => {
            'id': contact.id,
            'firstName': contact.firstName,
            'lastName': contact.lastName,
            'phoneNumber': contact.phoneNumber,
            'profileImageUrl': contact.profileImageUrl,
          },
        )
        .toList();
    await contactsListCacheInterface.saveContactsList(_contacts);
  }

  void _sortAndUpdateUsers(List<MyContact> users) {
    users.sort((a, b) => a.firstName.compareTo(b.firstName));
    state = users;
    log("Sort and update users: ${state.length}");
    _updateCacheContactsList(state);
  }

  void _revertDeleteContact(MyContact contact) async {
    state = [...state, contact];
    log("Revert delete contact: ${state.length}");
    _updateCacheContactsList(state);
  }

  void _revertAddContact(MyContact contact) async {
    state = state.where((c) => c.id != contact.id).toList();
    log("Revert add contact keep at: ${state.length}");
    _updateCacheContactsList(state);
  }

  void _revertUpdateContact(MyContact contact) async {
    state = state.map((c) {
      if (c.id == contact.id) {
        return contact;
      }
      return c;
    }).toList();

    log("Revert update contact: ${state.length}");
    _updateCacheContactsList(state);
  }

  List<MyContact> _matchPhoneContacts(
    List<MyContact> contacts,
    List<Contact> phoneContacts,
  ) {
    for (var myContact in contacts) {
      for (var phoneContact in phoneContacts) {
        // Normalize phone numbers by removing all non-digit characters
        String normalizedMyContactPhone = myContact.phoneNumber.replaceAll(
          RegExp(r'[^\d]'),
          '',
        );
        String normalizedPhoneContactNumber = phoneContact.phones[0].number
            .replaceAll(RegExp(r'[^\d]'), '');

        if (normalizedPhoneContactNumber == normalizedMyContactPhone) {
          myContact.contact = phoneContact;
        }
      }
    }
    return contacts;
  }

  // Load contacts from database and contacts controller
  Future<void> loadContacts() async {
    try {
      final phoneContacts = ref.read(contactsControllerProvider);
      final contacts = await ref.read(databaseInterfaceProvider).getAllUsers();

      final matchedContacts = _matchPhoneContacts(
        contacts.map((contact) => MyContact.fromJson(contact)).toList(),
        phoneContacts,
      );
      _sortAndUpdateUsers(matchedContacts);
    } catch (e) {
      log("Load contacts failed -> using cache: $e");
      ref
          .read(snackbarProvider.notifier)
          .showError('Please check your internet connection.');
      try {
        final contactsListCacheInterface = await ref.read(
          contactsListCacheInterfaceProvider.future,
        );
        final cachedContacts = await contactsListCacheInterface
            .getContactsList();
        log("Loaded ${cachedContacts.length} contacts from cache");

        if (cachedContacts.isNotEmpty) {
          final phoneContacts = ref.read(contactsControllerProvider);
          final matchedContacts = _matchPhoneContacts(
            cachedContacts
                .map((contact) => MyContact.fromJson(contact))
                .toList(),
            phoneContacts,
          );
          _sortAndUpdateUsers(matchedContacts);
        } else {
          log("No cached contacts found");
        }
      } catch (cacheError) {
        log("Error loading from cache: $cacheError");
        // Keep empty state if cache also fails
      }
    }
  }

  Future<void> saveContactToPhoneContacts(MyContact contact) async {
    final phoneContactsController = ref.read(
      contactsControllerProvider.notifier,
    );
    try {
      await phoneContactsController.createContact(
        firstName: contact.firstName,
        lastName: contact.lastName,
        phoneNumber: contact.phoneNumber,
      );
      await loadContacts();
      ref
          .read(snackbarProvider.notifier)
          .showSuccess('Contact saved to phone contacts');
    } catch (e) {
      ref
          .read(snackbarProvider.notifier)
          .showInfo('Please give permission to access your phone contacts');
    }
  }

  // Add contact
  Future<void> addContact(
    String firstName,
    String lastName,
    String phoneNumber,
    String profileImageUrl,
  ) async {
    // add user to local state optimistically
    final newContact = MyContact(
      contact: null,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
    );
    _sortAndUpdateUsers([...state, newContact]);
    try {
      // Try to add contact to the database
      await ref
          .read(databaseInterfaceProvider)
          .addUser(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            profileImageUrl: profileImageUrl,
          );

      //refetch contacts from database, id will be updated automatically
      await loadContacts();
    } catch (e) {
      // revert add contact to local state
      _revertAddContact(newContact);
      //No need to revert add contact as it is not in the database
      log("Add contact failed: $e");
      // throw exception here to prevent showing the "All Done" overlay
      throw Exception(e);
    }
  }

  // Delete contact
  Future<void> deleteContact(String contactId) async {
    // Track the deleted contact
    MyContact? deletedContact;
    // Delete contact optimistically
    _sortAndUpdateUsers(
      state.where((contact) {
        if (contact.id == contactId) {
          deletedContact = contact;
        }
        return contact.id != contactId;
      }).toList(),
    );

    try {
      await ref.read(databaseInterfaceProvider).deleteUser(userID: contactId);
    } catch (e) {
      if (deletedContact != null) {
        _revertDeleteContact(deletedContact!);
      }
      ref
          .read(snackbarProvider.notifier)
          .showError('Please check your internet connection.');
      log("Delete contact failed: $e");
    }
  }

  // Update contact
  Future<void> updateContact(MyContact updatedContact) async {
    // Track the updated contact for optimistic update
    MyContact? tempContact;
    final List<MyContact> updatedContacts = state.map((contact) {
      if (contact.id == updatedContact.id) {
        tempContact = contact;
        return contact.copyWith(
          contact: updatedContact.contact,
          firstName: updatedContact.firstName,
          lastName: updatedContact.lastName,
          phoneNumber: updatedContact.phoneNumber,
          profileImageUrl: updatedContact.profileImageUrl,
        );
      }
      return contact;
    }).toList();

    // Update the state optimistically
    _sortAndUpdateUsers(updatedContacts);

    try {
      // Update the contact in the database
      await ref
          .read(databaseInterfaceProvider)
          .updateUser(
            userID: updatedContact.id,
            firstName: updatedContact.firstName,
            lastName: updatedContact.lastName,
            phoneNumber: updatedContact.phoneNumber,
            profileImageUrl: updatedContact.profileImageUrl,
          );

      // If no error, we will reach this step with updatedContact (which is not null)
      await loadContacts();
    } catch (e) {
      if (tempContact != null) {
        _revertUpdateContact(tempContact!);
      }

      // Log the error
      log("Update contact failed: $e");
      throw Exception(e);
    }
  }

  // Search contacts
  Future<List<MyContact>> searchContacts(String query) async {
    final searchHistoryController = await ref.read(
      searchHistoryControllerProvider.future,
    );
    searchHistoryController.saveSearchedWord(query);

    if (query.isEmpty) {
      return state;
    }

    return state.where((contact) {
      final fullName = '${contact.firstName} ${contact.lastName}'.toLowerCase();
      return fullName.contains(query.toLowerCase());
    }).toList();
  }

  // Get image from camera
  Future<XFile?> getImageFromCamera() async {
    final picker = ImagePicker();
    try {
      final imageFile = await picker.pickImage(
        imageQuality: 90,
        source: ImageSource.camera,
        maxWidth: 600,
        maxHeight: 600,
      );

      if (imageFile == null) {
        return null;
      }

      return imageFile;
    } catch (e) {
      ref
          .read(snackbarProvider.notifier)
          .showInfo('Please check your camera permissions.');
      log("Get image from camera failed: $e");
      return null;
    }
  }

  // Get image from gallery
  Future<XFile?> getImageFromGallery() async {
    final picker = ImagePicker();
    try {
      final imageFile = await picker.pickImage(
        imageQuality: 100,
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
      );

      if (imageFile == null) {
        return null;
      }

      return imageFile;
    } catch (e) {
      ref
          .read(snackbarProvider.notifier)
          .showInfo('Please check your gallery permissions.');
      log("Get image from gallery failed: $e");
      return null;
    }
  }

  Future<String?> updateImage(MyContact updatedContact, XFile imageFile) async {
    try {
      final profileImageUrl = await ref
          .read(databaseInterfaceProvider)
          .uploadImage(imageFile: imageFile);

      await updateContact(
        updatedContact.copyWith(profileImageUrl: profileImageUrl),
      );

      return profileImageUrl;
    } catch (e) {
      // Show the error
      // Error of database is caught here
      ref
          .read(snackbarProvider.notifier)
          .showError('Please check your internet connection.');

      // Log the error
      log("Update image failed: $e");
      return null;
    }
  }

  Future<String?> immediateUpdateGallerySelected(
    MyContact updatedContact,
  ) async {
    final imageFile = await getImageFromGallery();
    if (imageFile != null) {
      return await updateImage(updatedContact, imageFile);
    }
    return null;
  }

  Future<String?> immediateUpdateCameraSelected(
    MyContact updatedContact,
  ) async {
    final imageFile = await getImageFromCamera();
    if (imageFile != null) {
      return await updateImage(updatedContact, imageFile);
    }
    return null;
  }
}

final homeScreenProvider =
    NotifierProvider<HomeScreenNotifier, List<MyContact>>(
      () => HomeScreenNotifier(),
    );
