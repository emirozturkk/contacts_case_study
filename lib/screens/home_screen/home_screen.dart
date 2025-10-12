import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contacts/providers/home_screen/home_screen_provider.dart';
import 'package:contacts/screens/home_screen/widgets/no_contact_home_screen/empty_contacts_widget.dart';
import 'package:contacts/screens/home_screen/widgets/bottom_sheets/add_or_edit_contact_bottom_sheet.dart';
import 'package:contacts/screens/home_screen/widgets/profile_card_widgets/grouped_contacts_list_widget.dart';
import 'package:contacts/app_common/data_members/mycontact.dart';
import 'package:contacts/screens/home_screen/widgets/search_widgets/search_bar.dart';
import 'package:contacts/app_common/snackbar/app_snackbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<MyContact> _filteredContacts = [];
  String _searchQuery = '';
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void _showAddContactBottomSheet(BuildContext context) {
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
          child: const AppSnackbarOverlay(child: AddOrEditContactBottomSheet()),
        ),
      ),
    );
  }

  Future<void> _onSearchChanged(String query) async {
    setState(() {
      _searchQuery = query;
    });

    if (query.isNotEmpty) {
      final filtered = await ref
          .read(homeScreenProvider.notifier)
          .searchContacts(query);
      setState(() {
        _filteredContacts = filtered;
      });
    } else {
      setState(() {
        _filteredContacts = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(homeScreenProvider);

    // Initialize filtered contacts if empty or search is empty
    if (_searchQuery.isEmpty) {
      _filteredContacts = contacts;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text(
          'Contacts',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF007AFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: () {
              focusNode.unfocus();
              _showAddContactBottomSheet(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          focusNode.unfocus();
        },
        child: contacts.isEmpty
            ? Container(
                color: Colors.white,
                child: EmptyContactsWidget(
                  onCreateContact: () => _showAddContactBottomSheet(context),
                ),
              )
            : Column(
                children: [
                  ExtendableSearchBar(
                    onSearchPressed: _onSearchChanged,
                    focusNode: focusNode,
                  ),
                  Expanded(
                    child: GroupedContactsListWidget(
                      contacts: _filteredContacts,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
