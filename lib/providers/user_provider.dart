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

  Future<void> updateProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();

    String? existingId = prefs.getString('user_id');
    String? existingDate = prefs.getString('member_since');

    final String userId =
        existingId ??
        "KES-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    final String memberSince =
        existingDate ?? DateFormat('MMMM yyyy').format(DateTime.now());

    state = UserData(
      name: name,
      email: email,
      userId: userId,
      memberSince: memberSince,
    );

    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_id', userId);
    await prefs.setString('member_since', memberSince);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserData>((ref) {
  return UserNotifier();
});
