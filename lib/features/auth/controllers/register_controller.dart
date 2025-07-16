import 'package:flutter/material.dart';
import 'package:new_words/dependency_injection.dart';
import 'package:new_words/entities/language.dart';
import 'package:new_words/common/constants/language_constants.dart';
import 'package:new_words/providers/auth_provider.dart';
import 'package:new_words/services/settings_service.dart';
import 'package:new_words/utils/util.dart';
import 'package:provider/provider.dart';

class RegisterController {
  final SettingsService _settingsService = locator<SettingsService>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? selectedNativeLanguage;
  String? selectedLearningLanguage;
  List<Language> supportedLanguages = [];
  bool isLoadingLanguages = false;
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // Callback to notify UI about submission state changes
  void Function(bool)? onSubmittingStateChanged;
  void Function(bool)? onLoadingLanguagesStateChanged;


  // Failsafe language list
  static const List<Language> _fallbackLanguages = LanguageConstants.supportedLanguages;

  Future<void> loadLanguages(BuildContext context) async {
    isLoadingLanguages = true;
    onLoadingLanguagesStateChanged?.call(true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final languages = await _settingsService.getSupportedLanguages();
      if (languages.isNotEmpty) {
        supportedLanguages = languages;
      } else {
        supportedLanguages = _fallbackLanguages;
        Util.showInfo(scaffoldMessenger, 'Empty language list received, using fallback.');
      }
    } catch (e) {
      supportedLanguages = _fallbackLanguages;
      Util.showError(scaffoldMessenger, 'Could not load languages. Using a default list.');
      debugPrint('Failed to load languages: $e'); // Log for developers
    } finally {
      isLoadingLanguages = false;
      onLoadingLanguagesStateChanged?.call(false);
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> submitForm(BuildContext context) async {
    if (_isSubmitting) return;
    if (formKey.currentState!.validate()) {
      final scaffoldMessenger = ScaffoldMessenger.of(context); // Capture ScaffoldMessenger
      if (selectedNativeLanguage == null || selectedLearningLanguage == null) {
        Util.showError(scaffoldMessenger, 'Please select both native and learning languages.');
        return;
      }
      if (selectedNativeLanguage == selectedLearningLanguage) {
        Util.showError(scaffoldMessenger, 'Native and learning languages cannot be the same.');
        return;
      }

      _isSubmitting = true;
      onSubmittingStateChanged?.call(true);

      final email = emailController.text;
      final password = passwordController.text;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // final navigator = Navigator.of(context); // Navigator is no longer needed here for success case

      try {
        final success = await authProvider.register(
          email,
          password,
          selectedNativeLanguage!,
          selectedLearningLanguage!,
        );

        if (success) {
          // User is auto-logged in by AuthProvider.register.
          Util.showInfo(scaffoldMessenger, 'Registration successful! Welcome.');
          
          // Navigation is handled by AuthWrapper reacting to AuthProvider state changes
        } else {
          if (authProvider.error != null) {
            Util.showError(scaffoldMessenger, authProvider.error!);
          } else {
            Util.showError(scaffoldMessenger, 'Registration failed. Please try again.');
          }
        }
      } catch (e) {
        Util.showError(scaffoldMessenger, 'An unexpected error occurred: ${e.toString()}');
      } finally {
        _isSubmitting = false;
        onSubmittingStateChanged?.call(false);
      }
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}