import 'package:flutter/material.dart';

class HistoryNameWidget extends StatelessWidget {
  final String name;
  final VoidCallback onSelected;
  final VoidCallback onDeleted;

  const HistoryNameWidget({
    super.key,
    required this.name,
    required this.onSelected,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.history, color: Colors.grey[600], size: 20),
      title: Text(name, style: const TextStyle(fontSize: 14)),
      onTap: () => onSelected(),
      dense: true,
      trailing: IconButton(
        icon: Icon(Icons.delete_rounded, color: Colors.red[300], size: 20),
        onPressed: () => onDeleted(),
      ),
    );
  }
}
