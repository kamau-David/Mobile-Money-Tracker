import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_screen.dart';
import '../providers/finance_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final userData = ref.watch(userProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _sectionHeader("Profile"),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF2E7D32),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              userData.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              userData.email.isEmpty ? "View profile details" : userData.email,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.payments_outlined, color: Color(0xFF2E7D32)),
            title: Text("Currency"),
            subtitle: Text("Kenyan Shilling (KES)"),
            trailing: Icon(Icons.lock_outline, size: 18),
          ),
          const Divider(),
          _sectionHeader("App Settings"),
          SwitchListTile(
            activeColor: const Color(0xFF2E7D32),
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.dark_mode_outlined,
              color: const Color(0xFF2E7D32),
            ),
            title: const Text("Dark Mode"),
            subtitle: const Text("Adjust the theme to your preference"),
            value: isDarkMode,
            onChanged: (bool value) {
              ref.read(themeProvider.notifier).toggleTheme(value);
            },
          ),
          const Divider(),
          _sectionHeader("Data Management"),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_outlined,
              color: Colors.red,
            ),
            title: const Text(
              "Clear All Data",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              "This will delete all your transactions permanently",
            ),
            onTap: () => _showDeleteDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
          const Divider(),
          _sectionHeader("About"),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("App Version"),
            subtitle: Text("1.0.0"),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Made with ❤️ for Personal Finance",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF2E7D32),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Clear All Data?"),
        content: const Text(
          "Are you sure? This action cannot be undone and all your spending history will be lost from this device.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(financeProvider.notifier).clearAllTransactions();
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("All data has been wiped."),
                    backgroundColor: Colors.black87,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text(
              "DELETE",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
