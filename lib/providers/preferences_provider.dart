import 'package:book_reader_app/providers/base_provider.dart';
import 'package:book_reader_app/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends BaseProvider {
  Map<String, dynamic> _preferences = {'theme': 'light', 'font_size': 16};

  final Api _api = Api();

  // Getters
  Map<String, dynamic> get preferences => _preferences;
  String get theme => _preferences['theme'] ?? 'light';
  int get fontSize => _preferences['font_size'] ?? 16;
  bool get isDarkMode => theme == 'dark';

  // Initialize from local storage (for offline support)
  Future<void> initFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme') ?? 'light';
    final savedFontSize = prefs.getInt('font_size') ?? 16;
    _preferences = {'theme': savedTheme, 'font_size': savedFontSize};
    notifyListeners();
  }

  // Save to local storage
  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    await prefs.setInt('font_size', fontSize);
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    final newTheme = isDarkMode ? 'light' : 'dark';
    await updatePreferences(theme: newTheme);
  }

  // Load preferences from API
  Future<void> loadPreferences() async {
    setBusy(true);
    try {
      final response = await _api.getPreferences();
      if (response['success'] == true) {
        _preferences = Map<String, dynamic>.from(response['data']);
        await _saveToLocal();
        setBusy(false);
      } else {
        // If API fails, load from local
        await initFromLocal();
        setBusy(false);
      }
    } catch (e) {
      // If API fails, load from local
      await initFromLocal();
      setBusy(false);
    }
  }

  // Update preferences
  Future<void> updatePreferences({String? theme, int? fontSize}) async {
    // Update local state immediately for smooth UI
    if (theme != null) _preferences['theme'] = theme;
    if (fontSize != null) _preferences['font_size'] = fontSize;
    await _saveToLocal();
    notifyListeners();

    // Sync with API in background
    try {
      await _api.updatePreferences(theme: theme, fontSize: fontSize);
    } catch (e) {
      // Silently fail - local storage is already updated
      setErrorMessage(e.toString());
    }
  }
}
