import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeUserId(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_id', userId);
}

Future<String?> getUserName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_name');
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_id');
}

Future<void> setUserId(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_id', userId);
}

Future<void> clearUserId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user_id');
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<void> logoutUser() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
  await prefs.remove('user_id');
}
