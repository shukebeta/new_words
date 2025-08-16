import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_words/providers/auth_provider.dart';
import 'package:new_words/services/account_service_v2.dart';
import 'package:new_words/dependency_injection.dart';
import 'package:new_words/generated/app_localizations.dart';

/// Dedicated screen for account deletion accessible via deep link
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  static const routeName = '/account/delete';

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isDeleting = false;
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;
  static const String _requiredText = 'I AGREE';

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_validateConfirmation);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateConfirmation() {
    setState(() {
      _isConfirmationValid = _confirmationController.text == _requiredText;
    });
  }

  Future<void> _proceedWithDeletion(BuildContext context) async {
    if (!_isConfirmationValid) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please type "$_requiredText" to confirm deletion'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

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
            Icon(
              Icons.warning_amber,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.finalWarningTitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text(localizations.deleteAccountFinalWarning),
            const SizedBox(height: 16),
            Text(localizations.finalConfirmationQuestion),
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
            child: Text('DELETE PERMANENTLY'),
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

    setState(() {
      _isDeleting = true;
    });

    try {
      await accountService.deleteAccount();
      
      if (context.mounted) {
        setState(() {
          _isDeleting = false;
        });
        
        // Clear local data and logout
        await authProvider.logout();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.accountDeletedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to login screen
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _isDeleting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.accountDeletionFailed}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.deleteAccount),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Make it responsive for web
          final isWideScreen = constraints.maxWidth > 600;
          final maxWidth = isWideScreen ? 600.0 : double.infinity;
          
          return Center(
            child: Container(
              width: maxWidth,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32, // Account for padding
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Check if user is authenticated
                      if (!authProvider.isAuthenticated) ...[
                        Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.login,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Login Required',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You must be logged in to delete your account. Please log in first.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                                  child: const Text('Login'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // User is authenticated, show deletion UI
                        Text(
                          localizations.deleteAccountSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          localizations.deleteAccountWarning,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.deleteAccountDataList,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('• ${localizations.deleteAccountData}'),
                        Text('• ${localizations.deleteSettingsData}'),
                        Text('• ${localizations.deleteVocabularyData}'),
                        Text('• ${localizations.deleteStoriesData}'),
                        Text('• ${localizations.deleteLearningProgressData}'),
                        const SizedBox(height: 24),
                        Text(
                          localizations.deleteAccountFinalWarning,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Confirmation input section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.typeToConfirm,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _confirmationController,
                                decoration: InputDecoration(
                                  hintText: localizations.typeIAgreeHere,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.error,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: _isConfirmationValid 
                                          ? Colors.green 
                                          : Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    _isConfirmationValid ? Icons.check_circle : Icons.error,
                                    color: _isConfirmationValid 
                                        ? Colors.green 
                                        : Theme.of(context).colorScheme.error,
                                  ),
                                  suffixText: _isConfirmationValid ? '✓' : '',
                                  suffixStyle: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isConfirmationValid 
                                      ? Colors.green 
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _confirmationController.text.isEmpty
                                    ? localizations.pleaseTypeExactText
                                    : _isConfirmationValid
                                        ? localizations.confirmationTextMatches
                                        : localizations.textMustMatchExactly,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _confirmationController.text.isEmpty
                                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                      : _isConfirmationValid
                                          ? Colors.green
                                          : Theme.of(context).colorScheme.error,
                                  fontWeight: _isConfirmationValid ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 16), // Space between input and button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (_isDeleting || !_isConfirmationValid) 
                                      ? null 
                                      : () => _proceedWithDeletion(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                    foregroundColor: Theme.of(context).colorScheme.onError,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                                  ),
                                  child: _isDeleting
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(localizations.deletingAccount),
                                          ],
                                        )
                                      : Text(
                                          _isConfirmationValid 
                                              ? localizations.deleteAccountPermanently 
                                              : localizations.typeIAgreeToEnable,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24), // Space before cancel button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
                            child: Text(localizations.cancelButton),
                          ),
                        ),
                        const SizedBox(height: 32), // Extra bottom padding for web
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}