import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_words/providers/auth_provider.dart'; // Updated import
import 'package:new_words/features/auth/presentation/register_page.dart'; // Uncommented
import 'package:new_words/features/home/presentation/home_screen.dart'; // Added for navigation

class LoginScreen extends StatefulWidget {
  static const routeName = '/login'; // For navigation

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );
      if (success && mounted) {
        // Navigate to home screen or appropriate screen
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName); // Updated
      } else if (!success && mounted) {
        // Error is handled by AuthProvider and displayed in the UI
        // SnackBar is already shown by the AuthProvider or can be shown here if preferred
        // For now, relying on the error text widget below the button.
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(authProvider.error ?? 'Login failed')),
        // );
      }
    }
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).pushNamed(RegisterPage.routeName); // Updated
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                  if (!value.contains('@')) { // Basic email validation
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
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (auth.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: const Text('Login'),
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
                onPressed: () => _navigateToRegister(context),
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}