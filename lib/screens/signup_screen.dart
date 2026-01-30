import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // 1. Form Key and Controllers
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

  // Email Validation Logic
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  void _submitData() async {
    // Triggers all 'validator' functions in the Form
    if (_formKey.currentState!.validate()) {
      // If valid, proceed to sign up
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey, // 🛡️ Form key handles the validation state
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
              const Text(
                "Join the KES Tracker community",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Full Name
              _buildTextFormField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person,
                validator: (val) => val!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),

              // Email with specific regex check
              _buildTextFormField(
                controller: _emailController,
                label: "Email Address",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 20),

              // Phone Number
              _buildTextFormField(
                controller: _phoneController,
                label: "Phone Number (M-Pesa)",
                icon: Icons.phone_android,
                hint: "07xxxxxxxx",
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val!.length < 10 ? 'Enter a valid phone number' : null,
              ),
              const SizedBox(height: 20),

              // Password
              TextFormField(
                controller: _passController,
                obscureText: !_isPasswordVisible,
                decoration: _inputStyle("Password", Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
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
                decoration: _inputStyle("Confirm Password", Icons.lock_reset),
                validator: (val) {
                  if (val != _passController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitData,
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for consistent styling
  InputDecoration _inputStyle(String label, IconData icon, [String? hint]) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildTextFormField({
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
      decoration: _inputStyle(label, icon, hint),
    );
  }
}
