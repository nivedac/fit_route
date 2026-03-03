import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class GeneratingPlanScreen extends StatefulWidget {
  const GeneratingPlanScreen({super.key});

  @override
  State<GeneratingPlanScreen> createState() => _GeneratingPlanScreenState();
}

class _GeneratingPlanScreenState extends State<GeneratingPlanScreen> {
  @override
  void initState() {
    super.initState();
    _checkProgress();
  }

  void _checkProgress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Wait for the simulated generation if not already finished
    while (userProvider.isGenerating) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    if (mounted) {
      // Clear the entire back stack (onboarding screens) and go to main app
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false, arguments: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final progress = userProvider.generationProgress;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Orbital Glows
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD0BCFF).withOpacity(0.03),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                
                // Loading Ring
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          valueColor: const AlwaysStoppedAnimation(Color(0xFFD0BCFF)),
                          backgroundColor: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const Text('CALCULATING', style: TextStyle(fontSize: 8, letterSpacing: 2, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 64),
                
                const Text(
                  'Generating your plan',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Our intelligence engine is processing your biological\nparameters for optimal accuracy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                ),
                
                const SizedBox(height: 48),
                
                // Status Steps
                _StatusRow(label: 'Analyzing profile metrics', isDone: progress > 0.3),
                _StatusRow(label: 'Customizing equipment loadout', isDone: progress > 0.6),
                _StatusRow(label: 'Calibrating caloric thresholds', isDone: progress > 0.8),
                
                const Spacer(),
                
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('VERSION 4.2.0 - ALPHA STABLE', style: TextStyle(fontSize: 8, letterSpacing: 3, fontWeight: FontWeight.bold, color: Colors.white24)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool isDone;

  const _StatusRow({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 48),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? const Color(0xFFD0BCFF) : Colors.transparent,
              border: Border.all(color: isDone ? const Color(0xFFD0BCFF) : Colors.white12),
            ),
            child: isDone ? const Icon(Icons.check, size: 12, color: Colors.black) : null,
          ),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(color: isDone ? Colors.white : Colors.white24, fontSize: 14, fontWeight: isDone ? FontWeight.w500 : FontWeight.normal)),
        ],
      ),
    );
  }
}
