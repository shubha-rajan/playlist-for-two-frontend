import 'package:shared_preferences/shared_preferences.dart';

class LoginHelper {

  static Future<String> getLoggedInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('UID') ?? '';
  }

  static Future<String> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? '';
  }

  static Future<String> getUserPhoto() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('imageUrl') ?? '';
  }


  static Future<bool> setLoggedInUser(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('UID', id);
  }

  static Future<bool> setUserName(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('name', name);
  }

  static Future<bool> setUserPhoto(String imageUrl) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('imageUrl', imageUrl);
  }

  static Future<bool> clearLoggedInUser()  async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}