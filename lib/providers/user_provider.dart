import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserData {
  final String name;
  final String email;
  final String userId;
  final String memberSince;

  UserData({
    required this.name,
    required this.email,
    required this.userId,
    required this.memberSince,
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

    state = UserData(
      name: name,
      email: email,
      userId: userId,
      memberSince: memberSince,
    );
  }

  /// Updates profile and ensures ID/Date are generated ONLY if they don't exist
  Future<void> updateProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();

    // Preserve existing ID or generate a new one if it's the first time
    String currentId = state.userId != "KES-000"
        ? state.userId
        : "KES-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

    // Preserve existing date or set it to 'now' if it's the first time
    String currentMemberSince = state.memberSince != "---"
        ? state.memberSince
        : DateFormat('MMMM yyyy').format(DateTime.now());

    state = UserData(
      name: name,
      email: email,
      userId: currentId,
      memberSince: currentMemberSince,
    );

    // Persist to local storage
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_id', currentId);
    await prefs.setString('member_since', currentMemberSince);
  }

  /// Resets user data (useful for Logout or wiping the device)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Wipes all SharedPreferences keys

    state = UserData(
      name: "User",
      email: "",
      userId: "KES-000",
      memberSince: "---",
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserData>((ref) {
  return UserNotifier();
});
