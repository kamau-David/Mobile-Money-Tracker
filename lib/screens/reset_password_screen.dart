import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String phoneNumber; // Passed from ForgotPasswordScreen
  const ResetPasswordScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Calling the method we added to the provider
        await ref
            .read(authProvider.notifier)
            .resetPassword(
              widget.phoneNumber,
              _codeController.text.trim(),
              _passController.text,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password updated successfully!")),
          );
          // Return to Login Screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
              const Icon(
                Icons.security_outlined,
                size: 80,
                color: primaryGreen,
              ),
              const SizedBox(height: 20),
              const Text(
                "New Password",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter the code sent to ${widget.phoneNumber}",
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
              ),
              const SizedBox(height: 40),

              // RESET CODE FIELD
              _buildField(
                isDark: isDark,
                controller: _codeController,
                label: "Reset Code",
                icon: Icons.pin,
                hint: "6-digit code",
                validator: (val) => val!.length < 4 ? "Enter valid code" : null,
              ),
              const SizedBox(height: 20),

              // NEW PASSWORD
              TextFormField(
                controller: _passController,
                obscureText: !_isPasswordVisible,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: _inputStyle("New Password", Icons.lock, isDark)
                    .copyWith(
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
                validator: (val) => val!.length < 4 ? "Min 4 characters" : null,
              ),
              const SizedBox(height: 20),

              // CONFIRM PASSWORD
              TextFormField(
                controller: _confirmPassController,
                obscureText: !_isPasswordVisible,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: _inputStyle(
                  "Confirm Password",
                  Icons.lock_reset,
                  isDark,
                ),
                validator: (val) => val != _passController.text
                    ? "Passwords do not match"
                    : null,
              ),

              const SizedBox(height: 40),

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
                  onPressed: _isLoading ? null : _handleReset,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "UPDATE PASSWORD",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSING YOUR UI HELPERS ---
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

  Widget _buildField({
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: _inputStyle(label, icon, isDark, hint),
    );
  }
}
