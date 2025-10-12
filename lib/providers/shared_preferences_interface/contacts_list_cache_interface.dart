import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:developer';

class ContactsListCacheInterface {
  final SharedPreferences preferences;
  static const String _keyContactsList = 'contacts_list';
  ContactsListCacheInterface({required this.preferences});

  // Save contacts list
  Future<void> saveContactsList(List<Map<String, dynamic>> contactsList) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyContactsList, json.encode(contactsList));
  }

  // Get contacts list
  Future<List<Map<String, dynamic>>> getContactsList() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsListString = prefs.getString(_keyContactsList);

    if (contactsListString == null ||
        contactsListString.isEmpty ||
        contactsListString == '[]') {
      return [];
    }

    try {
      final decodedData = json.decode(contactsListString);
      if (decodedData is List) {
        return decodedData.cast<Map<String, dynamic>>();
      } else {
        log("Cached data is not a list: $decodedData");
        return [];
      }
    } catch (e) {
      log("Error parsing cached contacts: $e");
      return [];
    }
  }
}

final contactsListCacheInterfaceProvider =
    FutureProvider<ContactsListCacheInterface>((ref) async {
      final preferences = await SharedPreferences.getInstance();
      return ContactsListCacheInterface(preferences: preferences);
    });
