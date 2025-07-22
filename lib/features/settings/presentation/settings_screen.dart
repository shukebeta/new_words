import 'package:flutter/material.dart';
import 'package:new_words/providers/auth_provider.dart';
import 'package:new_words/providers/locale_provider.dart';
import 'package:new_words/user_session.dart'; // Import UserSession
import 'package:new_words/services/account_service_v2.dart';
import 'package:new_words/services/settings_service_v2.dart';
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
  final SettingsServiceV2 _settingsService = locator<SettingsServiceV2>();
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

  String _getLanguageName(
    String? languageCode,
    AppLocalizations localizations,
  ) {
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
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      default:
        return languageCode;
    }
  }

  Future<void> _showUILanguageSelectionDialog(BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.uiLanguage),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Auto Detection option
                ListTile(
                  title: Text(localizations.autoDetection),
                  leading: Radio<String>(
                    value: 'auto',
                    groupValue: localeProvider.isAutoDetectMode ? 'auto' : localeProvider.currentLanguageCode,
                    onChanged: (value) async {
                      if (value == 'auto') {
                        await localeProvider.resetToAutoDetect();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                localizations.languageResetToAutoDetect,
                              ),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                const Divider(),
                // Manual language selection options
                ...LocaleProvider.supportedLocales.map((locale) {
                  return ListTile(
                    title: Text(_getUILanguageName(locale.languageCode)),
                    leading: Radio<String>(
                      value: locale.languageCode,
                      groupValue: localeProvider.isAutoDetectMode ? 'auto' : localeProvider.currentLanguageCode,
                      onChanged: (value) {
                        if (value != null) {
                          localeProvider.changeLocale(Locale(value, ''));
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                localizations.uiLanguageUpdatedSuccessfully,
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancelButton),
              ),
            ],
          ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.logout();

    // Data clearing and navigation are handled automatically by:
    // 1. AppStateProvider listening to AuthProvider state changes
    // 2. AuthWrapper handling navigation based on auth state
  }

  Future<void> _showDeleteAccountConfirmation(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteAccount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.deleteAccountWarning),
            const SizedBox(height: 16),
            Text(
              localizations.deleteAccountDataList,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text('• ${localizations.deleteAccountData}'),
            Text('• ${localizations.deleteSettingsData}'),
            Text('• ${localizations.deleteVocabularyData}'),
            Text('• ${localizations.deleteStoriesData}'),
            Text('• ${localizations.deleteLearningProgressData}'),
            const SizedBox(height: 16),
            Text(
              localizations.deleteAccountFinalWarning,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(localizations.deleteAccountConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _deleteAccount(context);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accountService = locator<AccountServiceV2>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(localizations.deletingAccount),
          ],
        ),
      ),
    );

    try {
      await accountService.deleteAccount();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Clear local data and logout
        await authProvider.logout();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.accountDeletedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.accountDeletionFailed}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showLanguageSelectionDialog(BuildContext context) async {
    final userSession = UserSession();
    await showDialog<void>(
      context: context,
      builder:
          (context) => LanguageSelectionDialog(
            currentNativeLanguage: userSession.nativeLanguage,
            currentLearningLanguage: userSession.currentLearningLanguage,
            onLanguagesSelected: (nativeLanguage, learningLanguage) async {
              final accountService = locator<AccountServiceV2>();
              await accountService.updateUserLanguages(
                nativeLanguage,
                learningLanguage,
              );
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
      appBar: AppBar(title: Text(localizations.settingsTitle)),
      body: Consumer2<AuthProvider, LocaleProvider>(
        // Wrap with Consumer2 to rebuild if auth state or locale changes
        builder: (context, auth, localeProvider, child) {
          // Access UserSession for language settings
          final userSession = UserSession();
          final nativeLang =
              _isLoadingLanguages
                  ? localizations.loading
                  : _getLanguageName(userSession.nativeLanguage, localizations);
          final learningLang =
              _isLoadingLanguages
                  ? localizations.loading
                  : _getLanguageName(
                    userSession.currentLearningLanguage,
                    localizations,
                  );
          final uiLang = localeProvider.isAutoDetectMode 
              ? '${localizations.autoDetection} (${_getUILanguageName(localeProvider.currentLanguageCode)})'
              : _getUILanguageName(localeProvider.currentLanguageCode);

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
                onTap:
                    _isLoadingLanguages
                        ? null
                        : () => _showLanguageSelectionDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: Text(localizations.learningLanguage),
                subtitle: Text(learningLang),
                trailing: const Icon(Icons.edit),
                onTap:
                    _isLoadingLanguages
                        ? null
                        : () => _showLanguageSelectionDialog(context),
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  localizations.logoutButton,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => _logout(context),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  localizations.deleteAccount,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                subtitle: Text(localizations.deleteAccountSubtitle),
                onTap: () => _showDeleteAccountConfirmation(context),
              ),
              // Add other settings items here as needed
            ],
          );
        },
      ),
    );
  }
}
