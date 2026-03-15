import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserData {
  final String name;
  final String email;
  final String userId;
  final String memberSince;
  final String? token; // ADDED: Spot for the Backend Key

  UserData({
    required this.name,
    required this.email,
    required this.userId,
    required this.memberSince,
    this.token, // Optional so it doesn't break initialization
  });
}

class UserNotifier extends StateNotifier<UserData> {
  UserNotifier()
    : super(
        UserData(
          name: "User",
          email: "",
          userId: "KES-000",
          memberSince: "---",
          token: null,
        ),
      ) {
    _loadUserData();
  }

  /// Loads stored user data from local storage on app start
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? "User";
    final email = prefs.getString('user_email') ?? "";
    final userId = prefs.getString('user_id') ?? "KES-000";
    final memberSince = prefs.getString('member_since') ?? "---";
    final token = prefs.getString('auth_token'); // Load the key

    state = UserData(
      name: name,
      email: email,
      userId: userId,
      memberSince: memberSince,
      token: token,
    );
  }

  /// UPDATED: This now handles the token from your Backend Login
  Future<void> setAuthenticatedUser({
    required String name,
    required String email,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    String currentId =
        "KES-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    String currentMemberSince = DateFormat('MMMM yyyy').format(DateTime.now());

    state = UserData(
      name: name,
      email: email,
      userId: currentId,
      memberSince: currentMemberSince,
      token: token,
    );

    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_id', currentId);
    await prefs.setString('member_since', currentMemberSince);
    await prefs.setString('auth_token', token); // Persist the key
  }

  /// Updates profile (Maintains your existing logic)
  Future<void> updateProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();

    String currentId = state.userId != "KES-000"
        ? state.userId
        : "KES-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

    String currentMemberSince = state.memberSince != "---"
        ? state.memberSince
        : DateFormat('MMMM yyyy').format(DateTime.now());

    state = UserData(
      name: name,
      email: email,
      userId: currentId,
      memberSince: currentMemberSince,
      token: state.token, // Preserve existing token
    );

    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_id', currentId);
    await prefs.setString('member_since', currentMemberSince);
  }

  /// Resets user data
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    state = UserData(
      name: "User",
      email: "",
      userId: "KES-000",
      memberSince: "---",
      token: null,
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserData>((ref) {
  return UserNotifier();
});
