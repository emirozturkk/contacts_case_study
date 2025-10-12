import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contacts/providers/home_screen/home_screen_provider.dart';
import 'package:contacts/providers/contacts_interface/device_contacts_controller_provider.dart';

class LoadingScreenProvider extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    await getAllUsers();
    return true;
  }

  Future<void> getAllUsers() async {
    await ref
        .read(contactsControllerProvider.notifier)
        .requestPermissionAndLoadContacts();
    await ref.read(homeScreenProvider.notifier).loadContacts();
  }
}

final loadingScreenProvider =
    AsyncNotifierProvider<LoadingScreenProvider, bool>(
      () => LoadingScreenProvider(),
    );
