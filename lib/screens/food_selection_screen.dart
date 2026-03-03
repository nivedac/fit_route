import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/user_provider.dart';

class FoodSelectionScreen extends StatefulWidget {
  const FoodSelectionScreen({super.key});

  @override
  State<FoodSelectionScreen> createState() => _FoodSelectionScreenState();
}

class _FoodSelectionScreenState extends State<FoodSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customFoodController = TextEditingController();

  final Map<String, List<Map<String, dynamic>>> _categories = {
    'Carbohydrates': [
      {'name': 'Basmati Rice', 'icon': Icons.grass},
      {'name': 'Rolled Oats', 'icon': Icons.bakery_dining},
    ],
    'Proteins': [
      {'name': 'Free Range Eggs', 'icon': Icons.egg},
      {'name': 'Chicken Breast', 'icon': Icons.kebab_dining},
    ],
    'Greens & Fruit': [
      {'name': 'Broccoli & Spinach', 'icon': Icons.eco},
      {'name': 'Mixed Berries', 'icon': Icons.restaurant},
    ],
  };

  List<String> _customFoods = [];
  String _searchQuery = '';

  void _showAddFoodDialog() {
    _customFoodController.clear();
    String selectedCategory = 'Carbohydrates';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Add Custom Food Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Add your own food to the selection list.',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
              const SizedBox(height: 24),

              // Food Name Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TextField(
                  controller: _customFoodController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'e.g. Greek Yogurt, Quinoa, Salmon...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(Icons.fastfood, color: Colors.white.withOpacity(0.4)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  dropdownColor: AppTheme.surface,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                  items: _categories.keys.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) {
                    if (val != null) setSheetState(() => selectedCategory = val);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Add Button
              ElevatedButton(
                onPressed: () {
                  final name = _customFoodController.text.trim();
                  if (name.isNotEmpty) {
                    setState(() {
                      _categories[selectedCategory]!.add({'name': name, 'icon': Icons.add_circle_outline});
                      _customFoods.add(name);
                    });
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    userProvider.toggleFood(name); // Auto-select it
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('\'$name\' added to $selectedCategory!'),
                        backgroundColor: AppTheme.accentEmerald,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentEmerald,
                  foregroundColor: AppTheme.charcoal,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Add Food Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                        onPressed: _showAddFoodDialog,
                        icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentEmerald),
                        tooltip: 'Add custom food',
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
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                            decoration: const InputDecoration(
                              hintText: 'Search ingredients...',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        else
                          const Icon(Icons.mic, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                
                // Food Lists
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
                    children: _categories.entries.map((entry) {
                      final filteredItems = entry.value.where((item) {
                        return _searchQuery.isEmpty || (item['name'] as String).toLowerCase().contains(_searchQuery);
                      }).toList();
                      if (filteredItems.isEmpty) return const SizedBox.shrink();
                      return _CategorySection(
                        title: entry.key,
                        items: filteredItems.map((item) => _FoodItem(name: item['name'] as String, icon: item['icon'] as IconData)).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            
            // Generate Button Overlay
            Positioned(
              bottom: 0,
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
                child: SafeArea(
                  top: false,
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
                        Icon(Icons.bolt),
                        SizedBox(width: 8),
                        Text('GENERATE PLAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ],
                    ),
                  ),
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
            border: Border.all(color: isSelected ? AppTheme.accentEmerald.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
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



