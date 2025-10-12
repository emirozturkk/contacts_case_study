import 'package:contacts/app_common/snackbar/widget/app_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contacts/app_common/data_members/mycontact.dart';
import 'package:contacts/screens/home_screen/widgets/bottom_sheets/photo_source_bottom_sheet.dart';
import 'package:contacts/screens/home_screen/widgets/bottom_sheets/add_or_edit_contact_bottom_sheet.dart';
import 'package:contacts/providers/home_screen/home_screen_provider.dart';
import 'package:contacts/screens/home_screen/widgets/common/profile_image_widget.dart';

class ContactScreen extends ConsumerStatefulWidget {
  final MyContact contact;

  const ContactScreen({super.key, required this.contact});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  late bool isExistInPhoneContacts;
  late String profileImageUrl;

  @override
  void initState() {
    super.initState();
    isExistInPhoneContacts = widget.contact.contact != null;
    profileImageUrl = widget.contact.profileImageUrl;
  }

  void _showPhotoSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AppSnackbarOverlay(
        child: PhotoSourceBottomSheet(
          onCameraSelected: () async {
            final newProfileImageUrl = await ref
                .read(homeScreenProvider.notifier)
                .immediateUpdateCameraSelected(widget.contact);
            if (newProfileImageUrl != null) {
              setState(() {
                profileImageUrl = newProfileImageUrl;
              });
            }
          },
          onGallerySelected: () async {
            final newProfileImageUrl = await ref
                .read(homeScreenProvider.notifier)
                .immediateUpdateGallerySelected(widget.contact);
            if (newProfileImageUrl != null) {
              setState(() {
                profileImageUrl = newProfileImageUrl;
              });
            }
          },
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, Offset position) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: <PopupMenuEntry<String>>[
        // Edit option
        PopupMenuItem<String>(
          value: 'edit',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: const [
              Icon(Icons.edit_outlined, color: Colors.black, size: 20),
              SizedBox(width: 12),
              Text(
                'Edit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        // Divider
        const PopupMenuDivider(height: 1),
        // Delete option
        PopupMenuItem<String>(
          value: 'delete',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: const [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text(
                'Delete',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        _showEditContact();
      } else if (value == 'delete') {
        _deleteContact();
      }
    });
  }

  void _showEditContact() {
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
            child: AddOrEditContactBottomSheet(contact: widget.contact),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteContact() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text(
          'Are you sure you want to delete ${widget.contact.firstName} ${widget.contact.lastName}?',
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

    if (shouldDelete == true && mounted) {
      await ref
          .read(homeScreenProvider.notifier)
          .deleteContact(widget.contact.id);
      if (mounted) {
        Navigator.pop(context); // Close contact detail screen
      }
    }
  }

  Future<void> _saveToPhoneContacts() async {
    try {
      await ref
          .read(homeScreenProvider.notifier)
          .saveContactToPhoneContacts(widget.contact);
      setState(() {
        isExistInPhoneContacts = true;
      });
    } catch (e) {
      setState(() {
        isExistInPhoneContacts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Three dots menu button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          final RenderBox button =
                              context.findRenderObject() as RenderBox;
                          final RenderBox overlay =
                              Overlay.of(context).context.findRenderObject()
                                  as RenderBox;
                          final Offset position = button.localToGlobal(
                            Offset(button.size.width, 50),
                            ancestor: overlay,
                          );
                          _showOptionsMenu(context, position);
                        },
                      );
                    },
                  ),
                ),
              ),

              // Profile photo with glow effect
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFB6C1).withValues(alpha: 0.3),
                          const Color(0xFFFFB6C1).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  // Profile photo
                  ProfileImageWidget(
                    imageUrl: profileImageUrl,
                    size: 150,
                    iconSize: 50,
                    firstName: widget.contact.firstName,
                    isCached: true,
                    imageFile: null,
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Change Photo button
              TextButton(
                onPressed: _showPhotoSourceBottomSheet,
                child: const Text(
                  'Change Photo',
                  style: TextStyle(color: Color(0xFF007AFF), fontSize: 16),
                ),
              ),

              const SizedBox(height: 24),

              // First Name field
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.contact.firstName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Last Name field
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.contact.lastName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Phone Number field
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.contact.phoneNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save to Phone MyContact button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isExistInPhoneContacts
                        ? null
                        : _saveToPhoneContacts,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: isExistInPhoneContacts
                            ? Colors.grey[300]!
                            : Colors.black,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          color: isExistInPhoneContacts
                              ? Colors.grey[400]
                              : Colors.black,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Save to My Phone Contact',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isExistInPhoneContacts
                                ? Colors.grey[400]
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Info message when already saved
              if (isExistInPhoneContacts) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This contact is already saved your phone.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
