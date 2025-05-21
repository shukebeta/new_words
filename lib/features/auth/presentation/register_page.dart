import 'package:flutter/material.dart';
import 'package:new_words/features/auth/controllers/register_controller.dart'; // Import RegisterController
import 'package:new_words/features/auth/presentation/login_screen.dart';
import 'package:new_words/entities/language.dart';
// Provider and AuthProvider might still be used for global state, but not directly for form/language logic here.
// import 'package:provider/provider.dart';
// import 'package:new_words/providers/auth_provider.dart';
// SettingsService and locator are used within the controller
// Util is used within the controller

class RegisterPage extends StatefulWidget {
  static const routeName = '/register';

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterController _controller = RegisterController();
  bool _isSubmittingUI = false;
  bool _isLoadingLanguagesUI = true; // Start true as languages load in initState

  @override
  void initState() {
    super.initState();
    _controller.onSubmittingStateChanged = (isSubmitting) {
      if (mounted) {
        setState(() {
          _isSubmittingUI = isSubmitting;
        });
      }
    };
    _controller.onLoadingLanguagesStateChanged = (isLoading) {
      if (mounted) {
        setState(() {
          _isLoadingLanguagesUI = isLoading;
        });
      }
    };
    // Load languages when the page initializes, after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Check mounted again before calling
        _controller.loadLanguages(context).then((_) {
          // Ensure UI updates after languages are loaded, if not already handled by callback
          if (mounted && _isLoadingLanguagesUI != _controller.isLoadingLanguages) {
            setState(() {
              _isLoadingLanguagesUI = _controller.isLoadingLanguages;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  Widget _buildLanguageDropdown({
    required String? currentValue,
    required ValueChanged<String?> onChanged,
    required String hintText,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: hintText,
        border: const OutlineInputBorder(), // Added border
      ),
      value: currentValue,
      hint: Text(hintText),
      isExpanded: true,
      items: _controller.supportedLanguages.map((Language lang) {
        return DropdownMenuItem<String>(
          value: lang.code,
          child: Text(lang.name),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select a language' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // final auth = Provider.of<AuthProvider>(context); // May still be used for global auth state

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center( // Added Center
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _controller.formKey, // Use controller's formKey
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _controller.emailController, // Use controller's emailController
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _controller.validateEmail, // Use controller's validator
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _controller.passwordController, // Use controller's passwordController
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: _controller.validatePassword, // Use controller's validator
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _controller.confirmPasswordController, // Use controller's confirmPasswordController
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: _controller.validateConfirmPassword, // Use controller's validator
                  textInputAction: TextInputAction.done, // Or .next if wanting to tab to dropdowns
                  onFieldSubmitted: (_) {
                    if (!_isLoadingLanguagesUI && !_isSubmittingUI) {
                      _controller.submitForm(context);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildLanguageDropdown(
                  currentValue: _controller.selectedNativeLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _controller.selectedNativeLanguage = newValue;
                    });
                  },
                  hintText: 'Which language do you speak?',
                ),
                const SizedBox(height: 12),
                _buildLanguageDropdown(
                  currentValue: _controller.selectedLearningLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _controller.selectedLearningLanguage = newValue;
                    });
                  },
                  hintText: 'Which language do you want to learn?',
                ),
                const SizedBox(height: 20),
                if (_isLoadingLanguagesUI)
                  const CircularProgressIndicator(semanticsLabel: 'Loading languages...')
                else if (_isSubmittingUI)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () => _controller.submitForm(context),
                    child: const Text('Register'),
                  ),
                // Removed direct error display:
                // if (auth.error != null && !auth.isLoading)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 8.0),
                //     child: Text(
                //       auth.error!,
                //       style: const TextStyle(color: Colors.red),
                //     ),
                //   ),
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