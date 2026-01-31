import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      // 1. Save to User Provider (updates UI & SharedPreferences)
      await ref
          .read(userProvider.notifier)
          .updateProfile(
            _nameController.text.trim(),
            _emailController.text.trim(),
          );

      // 2. Authenticate
      await ref
          .read(authProvider.notifier)
          .login(_nameController.text.trim(), _passController.text);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Icon(
                Icons.account_circle_outlined,
                size: 80,
                color: primaryGreen,
              ),
              const SizedBox(height: 20),
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              Text(
                "Join the KES Tracker community",
                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
              ),
              const SizedBox(height: 40),
              _buildTextFormField(
                isDark: isDark,
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person,
                validator: (val) => val!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                isDark: isDark,
                controller: _emailController,
                label: "Email Address",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                isDark: isDark,
                controller: _phoneController,
                label: "Phone Number (M-Pesa)",
                icon: Icons.phone_android,
                hint: "07xxxxxxxx",
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val!.length < 10 ? 'Enter a valid phone number' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passController,
                obscureText: !_isPasswordVisible,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: _inputStyle("Password", Icons.lock, isDark)
                    .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                    ),
                validator: (val) =>
                    val!.length < 4 ? 'Password too short (min 4)' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPassController,
                obscureText: !_isPasswordVisible,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: _inputStyle(
                  "Confirm Password",
                  Icons.lock_reset,
                  isDark,
                ),
                validator: (val) {
                  if (val != _passController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitData,
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Your helper methods remain the same
  InputDecoration _inputStyle(
    String label,
    IconData icon,
    bool isDark, [
    String? hint,
  ]) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white24 : Colors.grey.shade400,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
    );
  }

  Widget _buildTextFormField({
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: _inputStyle(label, icon, isDark, hint),
    );
  }
}
