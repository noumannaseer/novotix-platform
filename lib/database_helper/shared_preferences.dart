import 'package:shared_preferences/shared_preferences.dart';

class DataCache {
  static SharedPreferences preferences;

  static const String username = "username";
  static const String password = "password";
  static const String soundOnOff = "soundOnOff";
  static const String selectedEventId = "selectedEventId";

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }
}
