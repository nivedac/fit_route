import 'package:flutter/material.dart';
import '../theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.sunsetOrange.withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(height: 32),
                    // Bolt Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.sunsetOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.sunsetOrange.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.bolt, color: AppTheme.sunsetOrange, size: 32),
                    ),
                    const SizedBox(height: 40),
                    const Text.rich(
                      TextSpan(
                        text: 'Refine your\n',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.normal, height: 1.1),
                        children: [
                          TextSpan(
                            text: 'potential.',
                            style: TextStyle(color: AppTheme.sunsetOrange, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter your credentials to access your performance dashboard.',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 40),
                    
                    // Form Fields
                    _InputBox(
                      label: 'Email Address',
                      hint: 'name@email.com',
                      icon: Icons.mail_outline,
                    ),
                    const SizedBox(height: 20),
                    _InputBox(
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot password?', style: TextStyle(color: AppTheme.sunsetOrange, fontSize: 12)),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/goal-setup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.sunsetOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 8,
                        shadowColor: AppTheme.sunsetOrange.withOpacity(0.4),
                      ),
                      child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    
                    const SizedBox(height: 32),
                    
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
                      onPressed: () {},
                      icon: const Icon(Icons.account_circle_outlined, size: 24),
                      label: const Text('Google Account', style: TextStyle(color: Colors.white, fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        side: BorderSide(color: Colors.white.withOpacity(0.05)),
                        backgroundColor: Colors.white.withOpacity(0.02),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    Center(
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/create-account'),
                        child: Text.rich(
                          TextSpan(
                            text: 'Don\'t have an account? ',
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                            children: const [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(color: AppTheme.sunsetOrange, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;

  const _InputBox({
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.3), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.3), letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                TextField(
                  obscureText: isPassword,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          if (isPassword)
            Icon(Icons.visibility_off, color: Colors.white.withOpacity(0.3), size: 20),
        ],
      ),
    );
  }
}
