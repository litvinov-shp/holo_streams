import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs._();

  static late final SharedPreferences prefs;

  static Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
  }
}