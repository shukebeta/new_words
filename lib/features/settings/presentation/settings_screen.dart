import 'package:flutter/material.dart';
import 'package:new_words/providers/auth_provider.dart';
import 'package:new_words/user_session.dart'; // Import UserSession
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings'; // Example route name

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AuthProvider>( // Wrap with Consumer to rebuild if auth state changes (e.g., after logout)
        builder: (context, auth, child) {
          // Access UserSession for language settings
          final userSession = UserSession();
          final nativeLang = userSession.nativeLanguage ?? 'Not set';
          final learningLang = userSession.currentLearningLanguage ?? 'Not set';

          return ListView(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Native Language'),
                subtitle: Text(nativeLang),
                onTap: () {
                  // TODO: Navigate to a screen to change native language if needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Native Language: $nativeLang')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Learning Language'),
                subtitle: Text(learningLang),
                onTap: () {
                  // TODO: Navigate to a screen to change learning language if needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Learning Language: $learningLang')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Theme.of(context).colorScheme.error),
                title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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