import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_words/providers/auth_provider.dart';
import 'package:new_words/features/auth/presentation/login_screen.dart';
import 'package:new_words/features/auth/presentation/register_page.dart';
import 'package:new_words/features/home/presentation/home_screen.dart';
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
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

// The LoginOrHomeScreen widget is no longer needed with the AuthWrapper approach.
// class LoginOrHomeScreen extends StatelessWidget {
//   const LoginOrHomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthProvider>(context);
//     
//     if (!auth.isInitialized) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator(key: Key('init_loading'))),
//       );
//     }
//     
//     if (auth.isAuthenticated) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (Navigator.of(context).canPop()) { // Check if we can pop, to avoid issues if already on home
//            // This logic might be complex if LoginOrHomeScreen itself is part of the stack.
//         }
//         Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
//       });
//       return const Scaffold(body: Center(child: CircularProgressIndicator())); 
//     } else {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//          Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
//       });
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//   }
// }
