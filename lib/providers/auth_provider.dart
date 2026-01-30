import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isAuthenticated;
  final String? userName;

  AuthState({required this.isAuthenticated, this.userName});
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkStatus();
    return AuthState(isAuthenticated: false);
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    if (name != null) {
      state = AuthState(isAuthenticated: true, userName: name);
    }
  }

  Future<void> login(String name, String password) async {
    if (name.isNotEmpty && password.length >= 4) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      state = AuthState(isAuthenticated: true, userName: name);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);
