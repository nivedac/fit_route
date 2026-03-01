import 'package:flutter/material.dart';
import '../theme.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

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
                const _M3TextField(label: 'Full Name', placeholder: 'Full Name'),
                const SizedBox(height: 24),
                const _M3TextField(label: 'Email Address', placeholder: 'Email Address'),
                const SizedBox(height: 24),
                const _M3TextField(
                  label: 'Create Password',
                  placeholder: 'Password',
                  isPassword: true,
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (val) {},
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
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.sunsetOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  const _M3TextField({
    required this.label,
    required this.placeholder,
    this.isPassword = false,
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
