import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contacts/app_common/data_members/mycontact.dart';
import 'package:contacts/screens/profile_screen/contact_screen.dart';
import 'package:contacts/screens/home_screen/widgets/bottom_sheets/add_or_edit_contact_bottom_sheet.dart';
import 'package:contacts/providers/home_screen/home_screen_provider.dart';
import 'package:contacts/screens/home_screen/widgets/common/profile_image_widget.dart';
import 'package:contacts/app_common/snackbar/app_snackbar.dart';

class UserCardWidget extends ConsumerWidget {
  final MyContact contact;

  const UserCardWidget({super.key, required this.contact});

  void _showContactDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          color: Colors.white,
          child: AppSnackbarOverlay(child: ContactScreen(contact: contact)),
        ),
      ),
    );
  }

  void _showEditContact(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          color: Colors.white,
          child: AppSnackbarOverlay(
            child: AddOrEditContactBottomSheet(contact: contact),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text(
          'Are you sure you want to delete ${contact.firstName} ${contact.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await ref.read(homeScreenProvider.notifier).deleteContact(contact.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(contact.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left - Delete
          await _showDeleteConfirmation(context, ref);
          return false; // Don't dismiss automatically
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right - Edit
          _showEditContact(context);
          return false; // Don't dismiss automatically
        }
        return false;
      },
      background: Container(
        color: const Color(0xFF007AFF),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.edit, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: InkWell(
        onTap: () => _showContactDetails(context),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Badge(
                offset: const Offset(
                  -4,
                  -20,
                ), // Adjusted to position badge at bottom-right
                isLabelVisible: contact.contact != null,
                label: contact.contact != null
                    ? Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 14,
                        ),
                      )
                    : null,
                backgroundColor:
                    Colors.transparent, // Make default background transparent
                alignment: Alignment.bottomRight,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ProfileImageWidget(
                    imageUrl: contact.profileImageUrl,
                    size: 50,
                    iconSize: 50,
                    firstName: contact.firstName,
                    isCached: true,
                    imageFile: null,
                    isGlowEffect: false,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${contact.firstName} ${contact.lastName}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      contact.phoneNumber,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
