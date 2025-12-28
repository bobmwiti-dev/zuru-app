import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zuru_app/domain/models/auth_user.dart';

class AuthRepository {
  static const String _userKey = 'auth_user';
  static const String _tokenKey = 'auth_token';

  final SharedPreferences _prefs;

  AuthRepository(this._prefs);

  /// Returns the currently authenticated user if any
  Future<AuthUser?> getCurrentUser() async {
    try {
      final userJson = _prefs.getString(_userKey);
      if (userJson != null) {
        return AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Returns the current authentication token if any
  Future<String?> getToken() async {
    try {
      return _prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Saves the user and token to local storage
  Future<void> saveUser(AuthUser user, String token) async {
    try {
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      await _prefs.setString(_tokenKey, token);
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Clears all authentication data
  Future<void> clearUser() async {
    try {
      await _prefs.remove(_userKey);
      await _prefs.remove(_tokenKey);
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }

  /// Signs in a user with email and password
  Future<AuthUser> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would be an API call
    if (email == 'test@example.com' && password == 'password') {
      final user = AuthUser(
        email: email,
        name: 'Test User',
        lastLoginAt: DateTime.now(),
      );
      
      // In a real app, this token would come from your authentication server
      final token = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      
      await saveUser(user, token);
      return user;
    } else {
      throw Exception('Invalid email or password');
    }
  }

  /// Registers a new user
  Future<AuthUser> signUp(String email, String password, String name) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would be an API call
    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      final user = AuthUser(
        email: email,
        name: name,
        lastLoginAt: DateTime.now(),
      );
      
      // In a real app, this token would come from your authentication server
      final token = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      
      await saveUser(user, token);
      return user;
    } else {
      throw Exception('Please fill in all fields');
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await clearUser();
  }

  /// Checks if the user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}