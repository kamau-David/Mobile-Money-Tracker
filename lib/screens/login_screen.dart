import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Icon(
              Icons.lock_person_outlined,
              size: 80,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome Back",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            Text(
              "Login to manage your KES transactions",
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                hintText: "07xxxxxxxx",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
                prefixIcon: const Icon(
                  Icons.phone_android,
                  color: Color(0xFF2E7D32),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2E7D32),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passController,
              obscureText: !_isPasswordVisible,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF2E7D32)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2E7D32),
                    width: 2,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_phoneController.text.isNotEmpty &&
                      _passController.text.length >= 4) {
                    await ref
                        .read(authProvider.notifier)
                        .login(_phoneController.text, _passController.text);

                    if (mounted && ref.read(authProvider).isAuthenticated) {
                      Navigator.pushReplacementNamed(context, '/main');
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Invalid Phone or Password"),
                      ),
                    );
                  }
                },
                child: const Text(
                  "LOGIN",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
