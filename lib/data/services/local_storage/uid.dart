import 'package:shared_preferences/shared_preferences.dart';

class UIDStorage {
  static const String _uidKey = 'uid';

  /// Save UID
  Future<void> saveUID(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uidKey, uid);
  }

  /// Load UID
  Future<String?> getUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uidKey);
  }

  /// Clear UID
  Future<void> clearUID() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_uidKey);
  }
}

final UIDStorage uidStorage = UIDStorage();
