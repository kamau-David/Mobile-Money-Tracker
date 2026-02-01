import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userProvider);
    const primaryGreen = Color(0xFF2E7D32);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text(
          "Profile Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Your signature Green Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryGreen,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  userData.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Immutable Data Tiles
          _buildImmutableInfoTile(
            label: "Full Name",
            value: userData.name,
            icon: Icons.badge_outlined,
            isDark: isDark,
          ),
          _buildImmutableInfoTile(
            label: "Email Address",
            value: userData.email.isEmpty ? "Not provided" : userData.email,
            icon: Icons.email_outlined,
            isDark: isDark,
          ),
          _buildImmutableInfoTile(
            label: "Account ID",
            value: userData.userId,
            icon: Icons.fingerprint,
            isDark: isDark,
          ),
          _buildImmutableInfoTile(
            label: "Member Since",
            value: userData.memberSince,
            icon: Icons.calendar_today_outlined,
            isDark: isDark,
          ),

          const Spacer(),

          // Bottom Footer
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Account details are fixed system records and cannot be changed.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImmutableInfoTile({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
