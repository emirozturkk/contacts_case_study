import 'package:flutter/material.dart';
import 'package:contacts/screens/home_screen/widgets/search_widgets/history_name_widget.dart';

class ExpandedSearchHistoryWidget extends StatelessWidget {
  final List<String> searchHistory;
  final Function(String) onHistoryItemSelected;
  final Function(String) onHistoryDeleted;
  const ExpandedSearchHistoryWidget({
    super.key,
    required this.searchHistory,
    required this.onHistoryItemSelected,
    required this.onHistoryDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (searchHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1),
          ...(searchHistory
              .map(
                (query) => HistoryNameWidget(
                  name: query,
                  onSelected: () => onHistoryItemSelected(query),
                  onDeleted: () => onHistoryDeleted(query),
                ),
              )
              .toList()),
        ],
      ),
    );
  }
}
