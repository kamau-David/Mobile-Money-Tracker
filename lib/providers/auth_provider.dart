import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart'; // Ensure this import path is correct

class AuthState {
  final bool isAuthenticated;
  final String? userName;
  final String? token;
  final String? membershipId;
  final UserModel? user; // Added the full user model

  AuthState({
    required this.isAuthenticated,
    this.userName,
    this.token,
    this.membershipId,
    this.user,
  });
}

class AuthNotifier extends Notifier<AuthState> {
  final String _baseUrl = 'http://10.0.2.2:3000/api/auth';

  @override
  AuthState build() {
    _loadPersistedStatus();
    return AuthState(isAuthenticated: false);
  }

  Future<void> _loadPersistedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final name = prefs.getString('user_name');
    final mId = prefs.getString('membership_id');
    final userJson = prefs.getString('user_data'); // Check for full user data

    if (token != null) {
      UserModel? savedUser;
      if (userJson != null) {
        savedUser = UserModel.fromJson(jsonDecode(userJson));
      }

      state = AuthState(
        isAuthenticated: true,
        userName: name,
        token: token,
        membershipId: mId,
        user: savedUser,
      );
    }
  }

  Future<void> register(
    String name,
    String email,
    String phone,
    String password,
    String confirmPassword,
  ) async {
    final url = Uri.parse('$_baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': name,
          'email': email,
          'phone_number': phone,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        final newUser = UserModel.fromJson(data['user']);

        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_name', name);
        await prefs.setString('membership_id', newUser.membershipId);
        await prefs.setString('user_data', jsonEncode(newUser.toJson()));

        state = AuthState(
          isAuthenticated: true,
          userName: name,
          token: data['token'],
          membershipId: newUser.membershipId,
          user: newUser,
        );
      } else {
        throw data['error'] ?? 'Failed to register';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String phoneNumber, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final loggedInUser = UserModel.fromJson(data['user']);

        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_name', loggedInUser.name);
        await prefs.setString('membership_id', loggedInUser.membershipId);
        await prefs.setString('user_data', jsonEncode(loggedInUser.toJson()));

        state = AuthState(
          isAuthenticated: true,
          userName: loggedInUser.name,
          token: data['token'],
          membershipId: loggedInUser.membershipId,
          user: loggedInUser,
        );
      } else {
        throw data['error'] ?? 'Login failed';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> requestPasswordReset(String phoneNumber) async {
    final url = Uri.parse('$_baseUrl/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber}),
      );
      if (response.statusCode == 200) return true;
      final data = jsonDecode(response.body);
      throw data['error'] ?? 'Failed to send reset code';
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(
    String phoneNumber,
    String code,
    String newPassword,
  ) async {
    final url = Uri.parse('$_baseUrl/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'reset_code': code,
          'new_password': newPassword,
        }),
      );
      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw data['error'] ?? 'Failed to reset password';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);
