import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../theme.dart';
import '../services/auth_service.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreedToTerms = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }

    if (!_agreedToTerms) {
      _showError('Please agree to the Terms and Privacy Policy.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.registerUser(
        name: name,
        email: email,
        password: password,
      );
      // After successful registration, user is automatically signed in.
      // AuthGate will handle navigation to MainScreen.
      if (mounted) {
        // Navigate to goal setup for first-time users
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/goal-setup',
          (route) => false,
        );
      }
    } on FirebaseException catch (e) {
      _showError(AuthService.getErrorMessage(e));
    } catch (e) {
      _showError(AuthService.getErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final credential = await AuthService.signInWithGoogle();
      if (credential != null && mounted) {
        // After successful registration/login, AuthGate handles standard navigation
        // But for new users we might want to go to goal setup
        // Note: AuthService.signInWithGoogle already handles Firestore doc creation
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false,
        );
      }
    } on FirebaseException catch (e) {
      _showError(AuthService.getErrorMessage(e));
    } catch (e) {
      _showError(AuthService.getErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join our community and start your fitness evolution today.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 48),
                _M3TextField(
                  label: 'Full Name',
                  placeholder: 'Full Name',
                  controller: _nameController,
                ),
                const SizedBox(height: 24),
                _M3TextField(
                  label: 'Email Address',
                  placeholder: 'Email Address',
                  controller: _emailController,
                ),
                const SizedBox(height: 24),
                _M3TextField(
                  label: 'Create Password',
                  placeholder: 'Password',
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (val) {
                        setState(() => _agreedToTerms = val ?? false);
                      },
                      activeColor: AppTheme.sunsetOrange,
                      side: BorderSide(color: Colors.white.withOpacity(0.4)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text.rich(
                          TextSpan(
                            text: 'By registering, you agree to our ',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                            children: [
                              WidgetSpan(
                                child: InkWell(
                                  onTap: () => Navigator.pushNamed(context, '/terms'),
                                  child: const Text(
                                    'Terms',
                                    style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              WidgetSpan(
                                child: InkWell(
                                  onTap: () => Navigator.pushNamed(context, '/terms'),
                                  child: const Text(
                                    'Privacy Policy',
                                    style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.sunsetOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    disabledBackgroundColor: AppTheme.sunsetOrange.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                Center(
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Colors.white.withOpacity(0.4)),
                        children: const [
                          TextSpan(
                            text: 'Log in',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR CONTINUE WITH', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 2)),
                    ),
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
                  ],
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: const Icon(Icons.account_circle_outlined, size: 24),
                  label: const Text('Google Account', style: TextStyle(color: Colors.white, fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: BorderSide(color: Colors.white.withOpacity(0.05)),
                    backgroundColor: Colors.white.withOpacity(0.02),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _M3TextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final bool isPassword;
  final TextEditingController? controller;

  const _M3TextField({
    required this.label,
    required this.placeholder,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            suffixIcon: isPassword
                ? Icon(Icons.visibility, color: Colors.white.withOpacity(0.4))
                : null,
          ),
        ),
      ],
    );
  }
}
