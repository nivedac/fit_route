import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/user_provider.dart';

class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(
                    child: Text(
                      'Difficulty',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('STEP 3 OF 5', style: TextStyle(color: Color(0xFFCCFF00), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      Text('Profile Setup', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      value: 0.6,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation(Color(0xFFCCFF00)),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Set your baseline', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  SizedBox(height: 12),
                  Text(
                    'Choose the intensity that matches your current routine to optimize your AI coach.',
                    style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // List Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _DifficultyItem(
                    title: 'Beginner',
                    description: 'Starting fresh or returning. Focus on fundamentals and form.',
                    bars: 1,
                    isSelected: userProvider.difficulty == 'Beginner',
                    onTap: () => userProvider.setDifficulty('Beginner'),
                  ),
                  const SizedBox(height: 8),
                  _DifficultyItem(
                    title: 'Intermediate',
                    description: 'Regular training (2-3 times/week). Ready for more variety.',
                    bars: 2,
                    isSelected: userProvider.difficulty == 'Intermediate',
                    onTap: () => userProvider.setDifficulty('Intermediate'),
                  ),
                  const SizedBox(height: 8),
                  _DifficultyItem(
                    title: 'Advanced',
                    description: 'Consistent high performance. Seeking maximum intensity.',
                    bars: 3,
                    isSelected: userProvider.difficulty == 'Advanced',
                    onTap: () => userProvider.setDifficulty('Advanced'),
                  ),
                ],
              ),
            ),
            
            // Footer Action
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/diet-selection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCCFF00),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, size: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'HELP ME CHOOSE',
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyItem extends StatelessWidget {
  final String title;
  final String description;
  final int bars;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyItem({
    required this.title,
    required this.description,
    required this.bars,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A2A2A) : AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFFCCFF00).withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? const Color(0xFFCCFF00) : Colors.white24, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFCCFF00)),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.only(left: 3),
                            width: 5,
                            height: 14,
                            decoration: BoxDecoration(
                              color: index < bars ? const Color(0xFFCCFF00) : Colors.white10,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
