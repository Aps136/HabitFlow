import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
//thememodeprovider tells material app, in main.dart whcih theme to display
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<bool> {
  ThemeModeNotifier() : super(true) {
    _load();
  }

  // true = dark, false = light, sharedpreferences remembers the users choice
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDarkMode') ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', state);
  }
}