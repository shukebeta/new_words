import 'package:flutter/material.dart';
import 'package:new_words/providers/auth_provider.dart';
import 'package:new_words/providers/locale_provider.dart';
import 'package:new_words/user_session.dart'; // Import UserSession
import 'package:new_words/services/account_service.dart';
import 'package:new_words/services/settings_service.dart';
import 'package:new_words/entities/language.dart';
import 'package:new_words/common/constants/language_constants.dart';
import 'package:new_words/dependency_injection.dart';
import 'package:new_words/features/settings/presentation/language_selection_dialog.dart';
import 'package:new_words/generated/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings'; // Example route name

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = locator<SettingsService>();
  List<Language> _availableLanguages = [];
  bool _isLoadingLanguages = true;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    try {
      final languages = await _settingsService.getSupportedLanguages();
      if (languages.isNotEmpty) {
        setState(() {
          _availableLanguages = languages;
          _isLoadingLanguages = false;
        });
      } else {
        _useFallbackLanguages();
      }
    } catch (e) {
      debugPrint('Failed to load languages from API: $e');
      _useFallbackLanguages();
    }
  }

  void _useFallbackLanguages() {
    setState(() {
      _availableLanguages = LanguageConstants.supportedLanguages;
      _isLoadingLanguages = false;
    });
  }

  String _getLanguageName(String? languageCode, AppLocalizations localizations) {
    if (languageCode == null) return localizations.notSet;
    
    try {
      final language = _availableLanguages.firstWhere(
        (lang) => lang.code == languageCode,
      );
      return language.name;
    } catch (e) {
      // If not found in available languages, return the code
      return languageCode;
    }
  }

  String _getUILanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      default:
        return languageCode;
    }
  }

  Future<void> _showUILanguageSelectionDialog(BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.uiLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...LocaleProvider.supportedLocales.map((locale) {
              return ListTile(
                title: Text(_getUILanguageName(locale.languageCode)),
                leading: Radio<String>(
                  value: locale.languageCode,
                  groupValue: localeProvider.currentLanguageCode,
                  onChanged: (value) {
                    if (value != null) {
                      localeProvider.changeLocale(Locale(value, ''));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.uiLanguageUpdatedSuccessfully),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              );
            }),
            const Divider(),
            ListTile(
              title: const Text('Reset to Auto-Detect'),
              leading: const Icon(Icons.refresh),
              onTap: () async {
                await localeProvider.clearSavedLocale();
                await localeProvider.initializeLocale();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Language reset to auto-detect'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    // AuthWrapper in main.dart should handle navigation to LoginScreen
    // but explicitly navigating can be a fallback or ensure immediate effect.
    if (context.mounted) {
       // Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
       // The AuthWrapper should handle this automatically when listen:true in its build method.
       // If not, the above line can be used. For now, rely on AuthWrapper.
    }
  }

  Future<void> _showLanguageSelectionDialog(BuildContext context) async {
    final userSession = UserSession();
    await showDialog<void>(
      context: context,
      builder: (context) => LanguageSelectionDialog(
        currentNativeLanguage: userSession.nativeLanguage,
        currentLearningLanguage: userSession.currentLearningLanguage,
        onLanguagesSelected: (nativeLanguage, learningLanguage) async {
          final accountService = locator<AccountService>();
          await accountService.updateUserLanguages(nativeLanguage, learningLanguage);
          if (context.mounted) {
            final localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.languagesUpdatedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh the UI to show updated language names
            setState(() {});
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
      ),
      body: Consumer2<AuthProvider, LocaleProvider>( // Wrap with Consumer2 to rebuild if auth state or locale changes
        builder: (context, auth, localeProvider, child) {
          // Access UserSession for language settings
          final userSession = UserSession();
          final nativeLang = _isLoadingLanguages 
              ? localizations.loading 
              : _getLanguageName(userSession.nativeLanguage, localizations);
          final learningLang = _isLoadingLanguages 
              ? localizations.loading 
              : _getLanguageName(userSession.currentLearningLanguage, localizations);
          final uiLang = _getUILanguageName(localeProvider.currentLanguageCode);

          return ListView(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text(localizations.uiLanguage),
                subtitle: Text(uiLang),
                trailing: const Icon(Icons.edit),
                onTap: () => _showUILanguageSelectionDialog(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(localizations.nativeLanguage),
                subtitle: Text(nativeLang),
                trailing: const Icon(Icons.edit),
                onTap: _isLoadingLanguages ? null : () => _showLanguageSelectionDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: Text(localizations.learningLanguage),
                subtitle: Text(learningLang),
                trailing: const Icon(Icons.edit),
                onTap: _isLoadingLanguages ? null : () => _showLanguageSelectionDialog(context),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Theme.of(context).colorScheme.error),
                title: Text(localizations.logoutButton, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () => _logout(context),
              ),
              // Add other settings items here as needed
            ],
          );
        },
      ),
    );
  }
}