import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchHistoryController {
  final SharedPreferences preferences;
  static const String _keySearchHistory = 'search_history';
  SearchHistoryController({required this.preferences});

  // Save search word
  Future<void> saveSearchedWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searchHistory = prefs.getStringList(_keySearchHistory) ?? [];

    // Remove if already exists (to avoid duplicates)
    searchHistory.remove(word);

    // Add to the beginning
    searchHistory.insert(0, word);

    // Optional: Limit history to last 20 items
    if (searchHistory.length > 10) {
      searchHistory = searchHistory.sublist(0, 10);
    }

    await prefs.setStringList(_keySearchHistory, searchHistory);
  }

  // Get search history
  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySearchHistory) ?? [];
  }

  // Clear search history
  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySearchHistory);
  }

  // remove search word
  Future<void> removeSearchWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searchHistory = prefs.getStringList(_keySearchHistory) ?? [];
    if (searchHistory.remove(word)) {
      await prefs.setStringList(_keySearchHistory, searchHistory);
    }
  }
}

final searchHistoryControllerProvider = FutureProvider<SearchHistoryController>(
  (ref) async {
    final preferences = await SharedPreferences.getInstance();
    return SearchHistoryController(preferences: preferences);
  },
);
