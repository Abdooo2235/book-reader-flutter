import 'package:book_reader_app/providers/base_provider.dart';
import 'package:book_reader_app/services/api.dart';

class PreferencesProvider extends BaseProvider {
  Map<String, dynamic> _preferences = {
    'theme': 'light',
    'font_size': 16,
  };

  final Api _api = Api();

  // Getters
  Map<String, dynamic> get preferences => _preferences;
  String get theme => _preferences['theme'] ?? 'light';
  int get fontSize => _preferences['font_size'] ?? 16;

  // Load preferences
  Future<void> loadPreferences() async {
    setBusy(true);
    try {
      final response = await _api.getPreferences();
      if (response['success'] == true) {
        _preferences = Map<String, dynamic>.from(response['data']);
        setBusy(false);
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to load preferences');
        setBusy(false);
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
    }
  }

  // Update preferences
  Future<void> updatePreferences({
    String? theme,
    int? fontSize,
  }) async {
    setBusy(true);
    try {
      final response = await _api.updatePreferences(
        theme: theme,
        fontSize: fontSize,
      );
      if (response['success'] == true) {
        _preferences = Map<String, dynamic>.from(response['data']);
        setBusy(false);
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to update preferences');
        setBusy(false);
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
    }
  }
}

