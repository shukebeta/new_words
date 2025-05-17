import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_words/apis/vocabulary_api.dart'; // Import VocabularyApi
import 'package:new_words/providers/auth_provider.dart';
import 'package:new_words/providers/vocabulary_provider.dart'; // Import VocabularyProvider
import 'package:new_words/features/auth/presentation/login_screen.dart';
import 'package:new_words/features/auth/presentation/register_page.dart';
import 'package:new_words/features/home/presentation/home_screen.dart';
import 'package:new_words/features/main_menu/presentation/main_menu_screen.dart'; // Updated import
import 'package:new_words/dependency_injection.dart' as di;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  di.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VocabularyProvider(di.locator<VocabularyApi>())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Words',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Recommended for new apps
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('zh', ''), // Chinese, no country code
      ],
      home: const AuthWrapper(), // Use AuthWrapper for initial screen decision
      routes: {
        // Define routes for explicit navigation
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterPage.routeName: (context) => const RegisterPage(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        MainMenuScreen.routeName: (context) => const MainMenuScreen(), // Added MainMenuScreen route
      },
    );
  }
}

// AuthWrapper decides the initial screen based on authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to AuthProvider changes
    final auth = Provider.of<AuthProvider>(context);

    // If AuthProvider is still initializing, show a loading screen
    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(key: Key('auth_init_loading')),
        ),
      );
    }

    // Once initialized, show HomeScreen if authenticated, otherwise LoginScreen
    if (auth.isAuthenticated) {
      return const MainMenuScreen(); // Changed to MainMenuScreen
    } else {
      return const LoginScreen();
    }
  }
}
