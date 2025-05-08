import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_words/providers/auth_provider.dart'; // Updated import
import 'package:new_words/features/auth/presentation/login_screen.dart';
import 'package:new_words/features/auth/presentation/register_page.dart'; // Added import
import 'package:new_words/features/home/presentation/home_screen.dart';
import 'package:new_words/dependency_injection.dart' as di; // Added import for GetIt setup

void main() {
  // Ensure that the binding is initialized before using any Flutter APIs
  WidgetsFlutterBinding.ensureInitialized();
  di.init(); // Initialize GetIt dependencies
  
  runApp(
    MultiProvider(
      providers: [
        // AuthProvider is now sourced from lib/providers/auth_provider.dart
        // It uses GetIt internally to get AccountService, so no change here needed for its creation.
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Words',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
      // home: const LoginOrHomeScreen(), // Initial route handled by initialRoute or onGenerateRoute
      initialRoute: '/', // Or LoginOrHomeScreen.routeName if you make it a route
      routes: {
        '/': (context) => const LoginOrHomeScreen(), // Default route
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterPage.routeName: (context) => const RegisterPage(),
        HomeScreen.routeName: (context) => const HomeScreen(), // Assuming HomeScreen has a routeName
      },
    );
  }
}

class LoginOrHomeScreen extends StatelessWidget {
  const LoginOrHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    // Wait for AuthProvider to be initialized
    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(key: Key('init_loading'))), // Added key for clarity
      );
    }
    
    // If initialized and loading (e.g. during login/register attempt), show loading
    // This might be redundant if individual pages handle their own loading state during operations
    // if (auth.isLoading) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator(key: Key('op_loading'))),
    //   );
    // }

    if (auth.isAuthenticated) {
      // return const HomeScreen();
      // Using Navigator to ensure proper stack management if HomeScreen is also a route
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator())); // Placeholder while navigating
    } else {
      // return const LoginScreen();
      WidgetsBinding.instance.addPostFrameCallback((_) {
         Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator())); // Placeholder while navigating
    }
  }
}
