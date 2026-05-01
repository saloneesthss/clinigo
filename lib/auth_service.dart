import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  final DBHelper _db = DBHelper();

  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsLoggedIn = 'is_logged_in';

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final existing = await _db.getUserByEmail(email);
    if (existing != null) {
      return 'An account with this email already exists.';
    }

    final userId = await _db.insertUser({
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _saveSession(userId, name, email);
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final user = await _db.getUserByEmail(email);

    if (user == null) {
      return 'No account found with this email.';
    }
    if (user['password'] != password) {
      return 'Incorrect password.';
    }

    await _saveSession(user['id'], user['name'], user['email']);
    return null;
  }

  Future<void> _saveSession(int userId, String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }
}