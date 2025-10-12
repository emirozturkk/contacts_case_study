import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contacts/providers/home_screen/home_screen_provider.dart';
import 'package:contacts/screens/home_screen/widgets/bottom_sheets/photo_source_bottom_sheet.dart';
import 'package:contacts/screens/home_screen/widgets/animated_widgets/all_done.dart';
import 'package:contacts/app_common/data_members/mycontact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:contacts/providers/database/nexoft_database_provider.dart';
import 'package:contacts/screens/home_screen/widgets/common/profile_image_widget.dart';
import 'package:contacts/app_common/snackbar/app_snackbar.dart';

class AddOrEditContactBottomSheet extends ConsumerStatefulWidget {
  final MyContact? contact; // null means add mode, non-null means edit mode

  const AddOrEditContactBottomSheet({super.key, this.contact});

  @override
  ConsumerState<AddOrEditContactBottomSheet> createState() =>
      _AddOrEditContactBottomSheetState();
}

class _AddOrEditContactBottomSheetState
    extends ConsumerState<AddOrEditContactBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneNumberController;
  late String _profileImageUrl;
  XFile? _imageFile;

  bool get isEditMode => widget.contact != null;

  @override
  void initState() {
    super.initState();
    // Initialize with existing contact data if in edit mode
    _firstNameController = TextEditingController(
      text: widget.contact?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.contact?.lastName ?? '',
    );
    _phoneNumberController = TextEditingController(
      text: widget.contact?.phoneNumber ?? '',
    );
    _profileImageUrl = widget.contact?.profileImageUrl ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _showPhotoSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 1.0,
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => AppSnackbarOverlay(
        child: PhotoSourceBottomSheet(
          onCameraSelected: () async {
            final file = await ref
                .read(homeScreenProvider.notifier)
                .getImageFromCamera();
            setState(() {
              _imageFile = file;
            });
          },
          onGallerySelected: () async {
            final file = await ref
                .read(homeScreenProvider.notifier)
                .getImageFromGallery();
            setState(() {
              _imageFile = file;
            });
          },
        ),
      ),
    );
  }

  Future<void> _handleDone() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        String? profileImageUrl;
        if (_imageFile != null) {
          profileImageUrl = await ref
              .read(databaseInterfaceProvider)
              .uploadImage(imageFile: _imageFile!);
        }

        if (isEditMode) {
          // Update existing contact
          final updatedContact = widget.contact!.copyWith(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            profileImageUrl: profileImageUrl,
          );
          await ref
              .read(homeScreenProvider.notifier)
              .updateContact(updatedContact);
        } else {
          // Add new contact
          await ref
              .read(homeScreenProvider.notifier)
              .addContact(
                _firstNameController.text.trim(),
                _lastNameController.text.trim(),
                _phoneNumberController.text.trim(),
                profileImageUrl ?? "",
              );

          // Show the "All Done" overlay
          await showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.transparent,
            builder: (context) => AllDone(message: 'New contact saved 🎉'),
          );
        }
      } catch (e) {
        // Show the error
        ref
            .read(snackbarProvider.notifier)
            .showError('Please check your internet connection.');
      }

      // Close the bottom sheet
      if (mounted) {
        Navigator.pop(context);
      }
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
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      isEditMode ? 'Edit Contact' : 'New Contact',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: _handleDone,
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Form content - Made scrollable
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Profile photo
                        GestureDetector(
                          onTap: _showPhotoSourceBottomSheet,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Glow effect (only for edit mode with existing photo)
                                  if (isEditMode && _profileImageUrl.isNotEmpty)
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            const Color(
                                              0xFFFFB6C1,
                                            ).withValues(alpha: 0.3),
                                            const Color(
                                              0xFFFFB6C1,
                                            ).withValues(alpha: 0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ProfileImageWidget(
                                    imageUrl: _profileImageUrl,
                                    size: 120,
                                    iconSize: 50,
                                    firstName: _firstNameController.text,
                                    isCached: true,
                                    imageFile: _imageFile,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _profileImageUrl.isEmpty
                                    ? 'Add Photo'
                                    : 'Change Photo',
                                style: const TextStyle(
                                  color: Color(0xFF007AFF),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // First Name
                        TextFormField(
                          autocorrect: false,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            // Update avatar when first name changes
                            setState(() {});
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Last Name
                        TextFormField(
                          autocorrect: false,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        TextFormField(
                          autocorrect: false,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _phoneNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
