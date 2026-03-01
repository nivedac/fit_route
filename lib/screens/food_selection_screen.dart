import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/user_provider.dart';

class FoodSelectionScreen extends StatelessWidget {
  const FoodSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Sticky Header
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: AppTheme.charcoal.withOpacity(0.9),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Available Foods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
                
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search ingredients...',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const Icon(Icons.mic, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                
                // Food Lists
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
                    children: [
                      _CategorySection(
                        title: 'Carbohydrates',
                        items: [
                          _FoodItem(name: 'Basmati Rice', icon: Icons.grass),
                          _FoodItem(name: 'Rolled Oats', icon: Icons.bakery_dining),
                        ],
                      ),
                      _CategorySection(
                        title: 'Proteins',
                        items: [
                          _FoodItem(name: 'Free Range Eggs', icon: Icons.egg),
                          _FoodItem(name: 'Chicken Breast', icon: Icons.kebab_dining),
                        ],
                      ),
                      _CategorySection(
                        title: 'Greens & Fruit',
                        items: [
                          _FoodItem(name: 'Broccoli & Spinach', icon: Icons.eco),
                          _FoodItem(name: 'Mixed Berries', icon: Icons.restaurant),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Generate Button Overlay
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.charcoal.withOpacity(0), AppTheme.charcoal],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    userProvider.startGeneration();
                    Navigator.pushNamed(context, '/generating-plan');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentEmerald,
                    foregroundColor: AppTheme.charcoal,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.bolt, fontWeight: FontWeight.bold),
                      SizedBox(width: 8),
                      Text('GENERATE PLAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Navbar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _NavButton(icon: Icons.home, label: 'Home', isSelected: false),
                    _NavButton(icon: Icons.description, label: 'Plans', isSelected: true),
                    _NavButton(icon: Icons.assessment, label: 'Activity', isSelected: false),
                    _NavButton(icon: Icons.person, label: 'Profile', isSelected: false),
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

class _CategorySection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _CategorySection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }
}

class _FoodItem extends StatelessWidget {
  final String name;
  final IconData icon;

  const _FoodItem({required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isSelected = userProvider.selectedFoods.contains(name);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () => userProvider.toggleFood(name),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
                child: Icon(icon, color: Colors.white70, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
              Checkbox(
                value: isSelected,
                onChanged: (val) => userProvider.toggleFood(name),
                activeColor: AppTheme.accentEmerald,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(color: Colors.white24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _NavButton({required this.icon, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.accentEmerald : Colors.grey;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
