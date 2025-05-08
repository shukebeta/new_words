import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_words/providers/auth_provider.dart';
import 'package:new_words/features/auth/presentation/login_screen.dart'; // Uncommented
import 'package:new_words/features/home/presentation/home_screen.dart'; // Added for navigation (though not directly used here, good for consistency)

// Temporary hardcoded language list - replace with a more robust solution later
const List<Map<String, String>> _supportedLanguages = [
  {'code': 'en', 'name': 'English'},
  {'code': 'es', 'name': 'Spanish'},
  {'code': 'fr', 'name': 'French'},
  {'code': 'de', 'name': 'German'},
  {'code': 'it', 'name': 'Italian'},
  {'code': 'pt', 'name': 'Portuguese'},
  {'code': 'zh-CN', 'name': 'Chinese (Simplified)'},
  {'code': 'ja', 'name': 'Japanese'},
  {'code': 'ko', 'name': 'Korean'},
  {'code': 'ru', 'name': 'Russian'},
];

class RegisterPage extends StatefulWidget {
  static const routeName = '/register'; // For navigation

  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedNativeLanguage;
  String? _selectedLearningLanguage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedNativeLanguage == null || _selectedLearningLanguage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both native and learning languages.')),
        );
        return;
      }
      if (_selectedNativeLanguage == _selectedLearningLanguage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Native and learning languages cannot be the same.')),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _emailController.text,
        _passwordController.text,
        _selectedNativeLanguage!,
        _selectedLearningLanguage!,
      );

      if (success && mounted) {
        // Navigate to home screen or login screen
        // Navigator.of(context).pushReplacementNamed('/home'); // Example
         ScaffoldMessenger.of(context).showSnackBar( // Keep SnackBar for user feedback
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName); // Updated
      } else if (!success && mounted) {
        // Error is handled by AuthProvider and displayed in the UI
        // SnackBar is already shown by the AuthProvider or can be shown here if preferred
        // For now, relying on the error text widget below the button.
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(authProvider.error ?? 'Registration failed')),
        // );
      }
    }
  }

  void _navigateToLogin(BuildContext context) {
    // Navigator.of(context).pop(); // Assuming RegisterPage was pushed on top of Login
    // Use named route for consistency
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName); // Updated
  }

  Widget _buildLanguageDropdown({
    required String? currentValue,
    required ValueChanged<String?> onChanged,
    required String hintText,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: hintText),
      value: currentValue,
      hint: Text(hintText),
      isExpanded: true,
      items: _supportedLanguages.map((Map<String, String> lang) {
        return DropdownMenuItem<String>(
          value: lang['code'],
          child: Text(lang['name']!),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select a language' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Added for scrollability on smaller screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildLanguageDropdown(
                  currentValue: _selectedNativeLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedNativeLanguage = newValue;
                    });
                  },
                  hintText: 'Select Native Language',
                ),
                const SizedBox(height: 12),
                _buildLanguageDropdown(
                  currentValue: _selectedLearningLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLearningLanguage = newValue;
                    });
                  },
                  hintText: 'Select Learning Language',
                ),
                const SizedBox(height: 20),
                if (auth.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () => _register(context),
                    child: const Text('Register'),
                  ),
                if (auth.error != null && !auth.isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      auth.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => _navigateToLogin(context),
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}