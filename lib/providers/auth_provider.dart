import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthState {
  final bool isAuthenticated;
  final String? userName;
  final String? token;
  final String? membershipId; // For your new Membership ID feature

  AuthState({
    required this.isAuthenticated,
    this.userName,
    this.token,
    this.membershipId,
  });
}

class AuthNotifier extends Notifier<AuthState> {
  // Use your machine's IP address for the backend
  // 10.0.2.2 is the alias for localhost on Android emulators
  final String _baseUrl = 'http://10.0.2.2:3000/api/auth';

  @override
  AuthState build() {
    _loadPersistedStatus();
    return AuthState(isAuthenticated: false);
  }

  // Check if user is already logged in when app starts
  Future<void> _loadPersistedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final name = prefs.getString('user_name');
    final mId = prefs.getString('membership_id');

    if (token != null) {
      state = AuthState(
        isAuthenticated: true,
        userName: name,
        token: token,
        membershipId: mId,
      );
    }
  }

  // --- THE SIGNUP CONNECTION ---
  Future<void> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    final url = Uri.parse('$_baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Save the session data (Token and Membership ID)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_name', name);
        await prefs.setString('membership_id', data['user']['membership_id']);

        state = AuthState(
          isAuthenticated: true,
          userName: name,
          token: data['token'],
          membershipId: data['user']['membership_id'],
        );
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Failed to register';
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- THE LOGIN CONNECTION ---
  Future<void> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_name', data['user']['full_name']);
        await prefs.setString('membership_id', data['user']['membership_id']);

        state = AuthState(
          isAuthenticated: true,
          userName: data['user']['full_name'],
          token: data['token'],
          membershipId: data['user']['membership_id'],
        );
      } else {
        throw 'Invalid email or password';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears token and all user data
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);
