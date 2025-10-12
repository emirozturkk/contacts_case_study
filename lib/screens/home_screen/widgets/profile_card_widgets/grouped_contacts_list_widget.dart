import 'package:flutter/material.dart';
import 'package:contacts/app_common/data_members/mycontact.dart';
import 'package:contacts/screens/home_screen/widgets/profile_card_widgets/user_card_widget.dart';

class GroupedContactsListWidget extends StatelessWidget {
  final List<MyContact> contacts;

  const GroupedContactsListWidget({super.key, required this.contacts});

  Map<String, List<MyContact>> _groupContactsByFirstLetter() {
    final Map<String, List<MyContact>> grouped = {};

    for (var contact in contacts) {
      final firstLetter = contact.firstName.isNotEmpty
          ? contact.firstName[0].toUpperCase()
          : '#';

      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]!.add(contact);
    }

    // Sort the keys alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedMap = <String, List<MyContact>>{};
    for (var key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  @override
  Widget build(BuildContext context) {
    final groupedContacts = _groupContactsByFirstLetter();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedContacts.length,
      itemBuilder: (context, index) {
        final letter = groupedContacts.keys.elementAt(index);
        final contactsInGroup = groupedContacts[letter]!;

        return Container(
          margin: EdgeInsets.only(top: index == 0 ? 8 : 4, bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header with letter
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  color: Colors.grey[50],
                  width: double.infinity,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                // Contacts in this group
                ...contactsInGroup.map(
                  (contact) => UserCardWidget(contact: contact),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
