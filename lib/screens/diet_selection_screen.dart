import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/user_provider.dart';

class DietSelectionScreen extends StatelessWidget {
  const DietSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white70),
                    ),
                    const Expanded(
                      child: Text(
                        'DIETARY PREFERENCE',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.5, color: Colors.white60),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Step 5 of 5', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('100%', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation(Colors.white60),
                        minHeight: 4,
                     ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text.rich(
                      TextSpan(
                        text: 'Choose your ',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
                        children: [
                          TextSpan(
                            text: 'dietary fuel.',
                            style: TextStyle(color: Color(0xFF00FF9C)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Personalize your nutrition plan to match your lifestyle and goals.',
                      style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w300, height: 1.5),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Radio Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    _DietOption(
                      title: 'Vegetarian',
                      subtitle: 'Plant-based proteins and greens.',
                      icon: Icons.eco,
                      isSelected: userProvider.dietType == 'Vegetarian',
                      onTap: () => userProvider.setDietType('Vegetarian'),
                    ),
                    const SizedBox(height: 16),
                    _DietOption(
                      title: 'Non-Vegetarian',
                      subtitle: 'Animal and plant-based protein.',
                      icon: Icons.bolt,
                      isSelected: userProvider.dietType == 'Non-Vegetarian',
                      onTap: () => userProvider.setDietType('Non-Vegetarian'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // System Insight Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    color: Colors.black.withAlpha(50),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1490818387583-1baba5e638af?auto=format&fit=crop&q=80',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.psychology, size: 16, color: Colors.white.withOpacity(0.4)),
                                const SizedBox(width: 8),
                                const Text('SYSTEM INSIGHT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white38)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Macros are auto-adjusted based on your selection for optimal recovery.',
                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Footer
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/food-selection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF9C),
                        foregroundColor: AppTheme.charcoal,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                    const Text('BASELINE PHASE 2', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.5, color: Colors.white24)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DietOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DietOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF00FF9C) : Colors.white.withOpacity(0.1)),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF00FF9C).withOpacity(0.1), Colors.transparent],
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFF00FF9C) : Colors.white38, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? const Color(0xFF00FF9C) : Colors.white24),
                color: isSelected ? const Color(0xFF00FF9C) : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: AppTheme.charcoal) : null,
            ),
          ],
        ),
      ),
    );
  }
}
