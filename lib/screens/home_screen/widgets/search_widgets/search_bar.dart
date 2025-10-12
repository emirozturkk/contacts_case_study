import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contacts/providers/shared_preferences_interface/search_history_controller_provider.dart';
import 'package:contacts/screens/home_screen/widgets/search_widgets/expanded_search_history_widget.dart';

class ExtendableSearchBar extends ConsumerStatefulWidget {
  final Future<void> Function(String query) onSearchPressed;
  final FocusNode focusNode;
  const ExtendableSearchBar({
    super.key,
    required this.onSearchPressed,
    required this.focusNode,
  });

  @override
  ConsumerState<ExtendableSearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<ExtendableSearchBar> {
  final TextEditingController searchController = TextEditingController();
  bool _isExpanded = false;
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    _loadSearchHistory();
  }

  @override
  void dispose() {
    searchController.dispose();
    // Don't dispose focusNode here - it's owned by the parent widget
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isExpanded = widget.focusNode.hasFocus;
    });
  }

  Future<void> _loadSearchHistory() async {
    final historyController = await ref.read(
      searchHistoryControllerProvider.future,
    );
    final history = await historyController.getSearchHistory();
    if (mounted) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

  Future<void> _onItemSelectedDeleted(String query) async {
    final historyController = await ref.read(
      searchHistoryControllerProvider.future,
    );
    await historyController.removeSearchWord(query);
    await _loadSearchHistory();
  }

  Future<void> _onHistoryItemSelected(String query) async {
    searchController.text = query;
    await widget.onSearchPressed(query.trim().toLowerCase());
    setState(() {
      _isExpanded = false;
    });
    widget.focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            autocorrect: false,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            focusNode: widget.focusNode,
            onSubmitted: (value) async {
              await widget.onSearchPressed(value.trim().toLowerCase());
              await _loadSearchHistory();
            },
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by name',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) async {
              if (value.trim().isEmpty) {
                await widget.onSearchPressed('');
              }
            },
          ),
        ),
        if (_isExpanded)
          ExpandedSearchHistoryWidget(
            searchHistory: _searchHistory,
            onHistoryItemSelected: _onHistoryItemSelected,
            onHistoryDeleted: _onItemSelectedDeleted,
          ),
      ],
    );
  }
}
