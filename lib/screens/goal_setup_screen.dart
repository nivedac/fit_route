import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/user_provider.dart';

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Text('GOAL SETUP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            
            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('STEP 02 OF 05', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text('40%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentLime)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.4,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation(AppTheme.accentLime),
                      minHeight: 2,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                children: [
                  const Text('Refine your metrics', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Adjust your biological parameters to ensure precision-grade coaching calibration.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Weight Grid
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: 'Current (KG)',
                          value: userProvider.currentWeight.toStringAsFixed(0),
                          onChanged: (val) => userProvider.updateMetrics(current: double.tryParse(val)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _MetricCard(
                          label: 'Target (KG)',
                          value: userProvider.targetWeight.toStringAsFixed(0),
                          onChanged: (val) => userProvider.updateMetrics(target: double.tryParse(val)),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Height Input
                  _MetricCard(
                    label: 'Height (CM)',
                    value: userProvider.height.toStringAsFixed(0),
                    onChanged: (val) => userProvider.updateMetrics(height: double.tryParse(val)),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Age Slider
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('AGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                            Text.rich(TextSpan(
                              text: '${userProvider.age} ',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              children: const [TextSpan(text: 'yrs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey))],
                            )),
                          ],
                        ),
                        Slider(
                          value: userProvider.age.toDouble(),
                          min: 18,
                          max: 80,
                          activeColor: AppTheme.accentLime,
                          inactiveColor: Colors.white.withOpacity(0.1),
                          onChanged: (val) => userProvider.updateMetrics(age: val.toInt()),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Identity
                  const Text('IDENTITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _GenderButton(
                        label: 'MALE',
                        icon: Icons.male,
                        isSelected: userProvider.gender == 'Male',
                        onTap: () => userProvider.updateMetrics(gender: 'Male'),
                      ),
                      const SizedBox(width: 12),
                      _GenderButton(
                        label: 'FEMALE',
                        icon: Icons.female,
                        isSelected: userProvider.gender == 'Female',
                        onTap: () => userProvider.updateMetrics(gender: 'Female'),
                      ),
                      const SizedBox(width: 12),
                      _GenderButton(
                        label: 'OTHER',
                        icon: Icons.person_outline,
                        isSelected: userProvider.gender == 'Other',
                        onTap: () => userProvider.updateMetrics(gender: 'Other'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Timeline
                  const Text('TIMELINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: userProvider.timeline,
                        dropdownColor: AppTheme.surface,
                        isExpanded: true,
                        items: ['30 Days', '60 Days', '90 Days'].map((e) {
                          return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)));
                        }).toList(),
                        onChanged: (val) => userProvider.updateMetrics(timeline: val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            
            // Bottom Button
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0), Colors.black],
                ),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/workout-selection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentLime,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatefulWidget {
  final String label;
  final String value;
  final Function(String) onChanged;

  const _MetricCard({required this.label, required this.value, required this.onChanged});

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  late TextEditingController _controller;
  bool _isUserEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _MetricCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update text from outside if the user is NOT currently editing
    if (!_isUserEditing && widget.value != oldWidget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() => _isUserEditing = hasFocus);
              // When user leaves the field, if it's empty, reset to 0
              if (!hasFocus && _controller.text.isEmpty) {
                _controller.text = '0';
                widget.onChanged('0');
              }
            },
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '0',
                hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              onChanged: (val) {
                // Allow empty value so user can fully clear and retype
                if (val.isEmpty) {
                  return; // Don't call onChanged with empty — wait for user to type new value
                }
                widget.onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentLime : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppTheme.accentLime : Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.black : Colors.grey, size: 24),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
