import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../theme.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Please enter your email address.', isError: true);
      return;
    }

    // Basic email format check
    if (!email.contains('@') || !email.contains('.')) {
      _showMessage('Please enter a valid email address.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.resetPassword(email: email);
      if (mounted) {
        _showMessage('Reset link sent! Check your email.', isError: false);
      }
    } on FirebaseException catch (e) {
      _showMessage(AuthService.getErrorMessage(e), isError: true);
    } catch (e) {
      _showMessage(AuthService.getErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppTheme.sunsetOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Forgot Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.sunsetOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.lock_reset, color: AppTheme.sunsetOrange, size: 36),
                      ),
                      const SizedBox(height: 32),

                      // Title
                      const Text(
                        'Reset your password',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter the email address associated with your fitness account and we\'ll send you a secure link to reset your password.',
                        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5), height: 1.5),
                      ),
                      const SizedBox(height: 40),

                      // Email Input
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.sunsetOrange.withOpacity(0.5), width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.mail_outline, color: Colors.white.withOpacity(0.4)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email address',
                                  labelStyle: TextStyle(color: AppTheme.sunsetOrange, fontSize: 12, fontWeight: FontWeight.w500),
                                  hintText: 'yourname@fitness.com',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Send Reset Link Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleResetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.sunsetOrange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 8,
                          shadowColor: AppTheme.sunsetOrange.withOpacity(0.3),
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
                            : const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),

                      const Spacer(),

                      // Footer
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Text.rich(
                              TextSpan(
                                text: 'Remember your password? ',
                                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                                children: const [
                                  TextSpan(
                                    text: 'Log In',
                                    style: TextStyle(color: AppTheme.sunsetOrange, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
