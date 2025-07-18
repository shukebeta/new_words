import 'package:flutter/material.dart';
import 'package:new_words/utils/util.dart';
import 'package:new_words/providers/auth_provider.dart'; // Required for AuthProvider interaction
import 'package:provider/provider.dart'; // Required for Provider

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // Callback to notify UI about submission state changes
  void Function(bool)? onSubmittingStateChanged;

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or username';
    }
    if (!value.contains('@')) {
      // Basic email validation
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  Future<void> submitForm(BuildContext context) async {
    if (_isSubmitting) return;
    if (formKey.currentState!.validate()) {
      _isSubmitting = true;
      onSubmittingStateChanged?.call(true);

      final email = emailController.text;
      final password = passwordController.text;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final scaffoldMessenger = ScaffoldMessenger.of(
        context,
      ); // Capture ScaffoldMessenger
      // final navigator = Navigator.of(context); // Navigator is no longer needed here for success case

      try {
        final success = await authProvider.login(email, password);

        if (success) {
          // Navigation is now handled by AuthWrapper reacting to AuthProvider state changes.
          // No explicit navigation here.
          // Optionally, show a success message if desired, though usually not needed for login.
          // Util.showInfo(scaffoldMessenger, 'Login successful!');
        } else {
          // Error is handled by AuthProvider, and we display it via Util.showError
          // If AuthProvider doesn't show a snackbar, we can add one here.
          if (authProvider.error != null) {
            Util.showError(scaffoldMessenger, authProvider.error!);
          } else {
            Util.showError(
              scaffoldMessenger,
              'Login failed. Please try again.',
            );
          }
        }
      } catch (e) {
        Util.showError(
          scaffoldMessenger,
          'An unexpected error occurred: ${e.toString()}',
        );
      } finally {
        _isSubmitting = false;
        onSubmittingStateChanged?.call(false);
      }
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
