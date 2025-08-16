import 'package:flutter/material.dart';
import 'package:new_words/features/auth/controllers/login_controller.dart'; // Import LoginController
import 'package:new_words/common/constants/routes.dart';
// Provider is still needed if AuthProvider is used for global state, but not directly for form logic here.
// import 'package:provider/provider.dart';
// import 'package:new_words/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();
  bool _isPasswordVisible = false;
  // _isSubmitting will be managed by the controller's callback
  bool _isSubmittingUI = false;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.register);
  }

  @override
  Widget build(BuildContext context) {
    // final auth = Provider.of<AuthProvider>(context); // AuthProvider might still be used for global state like isLoading or error

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        // Added Center for better layout
        child: SingleChildScrollView(
          // Added SingleChildScrollView
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _controller.formKey, // Use controller's formKey
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller:
                      _controller
                          .emailController, // Use controller's emailController
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(), // Added border
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      _controller
                          .validateUsername, // Use controller's validator
                  textInputAction:
                      TextInputAction.next, // Added: Move to next field
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller:
                      _controller
                          .passwordController, // Use controller's passwordController
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(), // Added border
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator:
                      _controller
                          .validatePassword, // Use controller's validator
                  onFieldSubmitted: (_) {
                    // Ensure not submitting already
                    if (!_isSubmittingUI) {
                      _controller.submitForm(context);
                    }
                  },
                  textInputAction:
                      TextInputAction.done, // Added: Show 'done' action
                ),
                const SizedBox(height: 20),
                if (_isSubmittingUI) // Use local UI state for progress indicator
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // Added style for better appearance
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () => _controller.submitForm(context),
                    child: const Text('Login'),
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
                  onPressed: () => _navigateToRegister(context),
                  child: const Text('Don\'t have an account? Register'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/privacy-policy'),
                  child: const Text('Privacy Policy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
