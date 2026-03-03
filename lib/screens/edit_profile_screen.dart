import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  bool _workoutReminders = true;
  bool _macroTracking = true;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.fullName.isEmpty ? 'Alex Sterling' : userProvider.fullName);
    _emailController = TextEditingController(text: userProvider.email.isEmpty ? 'alex.sterling@fitness.com' : userProvider.email);
    _bioController = TextEditingController(text: 'Certified HIIT instructor and nutrition enthusiast. On a journey to run my first marathon!');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      appBar: AppBar(
        backgroundColor: AppTheme.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              final provider = Provider.of<UserProvider>(context, listen: false);
              provider.updateAccount(_nameController.text, _emailController.text);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile saved successfully!'),
                  backgroundColor: AppTheme.sunsetOrange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: AppTheme.sunsetOrange, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Photo
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.sunsetOrange.withOpacity(0.3), width: 2),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.sunsetOrange,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.charcoal, width: 4),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('FULL NAME'),
                  const SizedBox(height: 8),
                  _buildTextField(_nameController, 'Enter your name'),
                  const SizedBox(height: 24),
                  
                  _buildLabel('EMAIL ADDRESS'),
                  const SizedBox(height: 8),
                  _buildTextField(_emailController, 'Enter your email'),
                  const SizedBox(height: 24),
                  
                  _buildLabel('BIO'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      controller: _bioController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Tell us about your fitness goals...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Preferences
                  const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildToggle(Icons.fitness_center, 'Workout Reminders', _workoutReminders, (val) {
                    setState(() => _workoutReminders = val);
                  }),
                  const SizedBox(height: 12),
                  _buildToggle(Icons.restaurant_menu, 'Macro Tracking', _macroTracking, (val) {
                    setState(() => _macroTracking = val);
                  }),

                  const SizedBox(height: 40),

                  // Delete Account
                  Center(
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppTheme.surface,
                            title: const Text('Delete Account?', style: TextStyle(color: Colors.white)),
                            content: const Text('This action cannot be undone. All your data will be permanently deleted.', style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                      },
                      child: const Text('Delete Account', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, letterSpacing: 1),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildToggle(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.sunsetOrange),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.sunsetOrange,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}
