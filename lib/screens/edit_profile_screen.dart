import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  bool _isUploadingPhoto = false;
  String? _localPhotoPath;

  // Workout and Diet preferences
  late String _selectedWorkoutMode;
  late String _selectedDietType;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.fullName.isEmpty ? '' : userProvider.fullName);
    _emailController = TextEditingController(text: userProvider.email.isEmpty ? '' : userProvider.email);
    _bioController = TextEditingController(text: '');
    _selectedWorkoutMode = userProvider.workoutEnvironment;
    _selectedDietType = userProvider.dietType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Choose Photo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.sunsetOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.camera_alt, color: AppTheme.sunsetOrange),
              ),
              title: const Text('Camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              subtitle: const Text('Take a new photo', style: TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(ctx);
                _handlePhotoSelection(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.photo_library, color: Colors.blueAccent),
              ),
              title: const Text('Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              subtitle: const Text('Choose from gallery', style: TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(ctx);
                _handlePhotoSelection(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePhotoSelection(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (pickedFile == null) return;

      // Verify the file exists and is valid
      final file = File(pickedFile.path);
      if (!await file.exists()) {
        _showError('Selected image file not found.');
        return;
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        _showError('Selected image file is empty.');
        return;
      }

      setState(() {
        _isUploadingPhoto = true;
        _localPhotoPath = pickedFile.path;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('You must be logged in to upload a photo.');
        return;
      }

      // Upload to Firebase Storage with proper error handling
      final storagePath = 'profile_photos/${user.uid}.jpg';
      final ref = FirebaseStorage.instance.ref().child(storagePath);

      debugPrint('Uploading photo to: $storagePath (size: $fileSize bytes)');

      // Upload the file using putData for more reliable uploads
      final bytes = await file.readAsBytes();
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Monitor upload progress with proper error handling on stream
      final subscription = uploadTask.snapshotEvents.listen(
        (event) {
          if (event.totalBytes > 0) {
            final progress = event.bytesTransferred / event.totalBytes;
            debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
          }
        },
        onError: (e) {
          debugPrint('Upload stream error: $e');
          // Error will be caught by the await below
        },
        cancelOnError: true,
      );

      try {
        // Wait for upload to complete
        final snapshot = await uploadTask;
        debugPrint('Upload complete. State: ${snapshot.state}');

        if (snapshot.state != TaskState.success) {
          _showError('Upload failed. Please try again.');
          return;
        }

        // Get the download URL AFTER successful upload
        final downloadUrl = await ref.getDownloadURL();
        debugPrint('Download URL: $downloadUrl');

        // Update provider and Firestore
        if (!mounted) return;
        final provider = Provider.of<UserProvider>(context, listen: false);
        provider.setProfilePhotoUrl(downloadUrl);
        await provider.saveUserProfile(user.uid);
      } finally {
        await subscription.cancel();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile photo updated! 📸'),
            backgroundColor: AppTheme.sunsetOrange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } on FirebaseException catch (e) {
      debugPrint('Firebase error: ${e.code} - ${e.message}');
      String errorMsg;
      switch (e.code) {
        case 'object-not-found':
          errorMsg = 'Storage not configured. Please enable Firebase Storage in the Firebase Console.';
          break;
        case 'unauthorized':
        case 'unauthenticated':
          errorMsg = 'Permission denied. Please check Firebase Storage rules.';
          break;
        case 'canceled':
          errorMsg = 'Upload was cancelled.';
          break;
        case 'unknown':
          errorMsg = 'Upload failed. Please check your internet connection and ensure Firebase Storage is enabled in the Firebase Console.';
          break;
        default:
          errorMsg = 'Upload failed: ${e.message ?? e.code}';
      }
      _showError(errorMsg);
    } catch (e) {
      debugPrint('Unexpected error: $e');
      _showError('Failed to update photo. Please try again.');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final photoUrl = provider.profilePhotoUrl;

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
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              provider.updateAccount(_nameController.text, _emailController.text);
              provider.setWorkoutEnvironment(_selectedWorkoutMode);
              provider.setDietType(_selectedDietType);
              if (user != null) {
                await provider.saveUserProfile(user.uid);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Profile saved successfully!'),
                    backgroundColor: AppTheme.sunsetOrange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
                Navigator.pop(context);
              }
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
                        color: AppTheme.sunsetOrange.withOpacity(0.15),
                      ),
                      child: ClipOval(
                        child: _buildProfileImage(photoUrl),
                      ),
                    ),
                    GestureDetector(
                      onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.sunsetOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.charcoal, width: 4),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                        ),
                        child: Icon(
                          _isUploadingPhoto ? Icons.hourglass_top : Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
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

                  // Workout & Diet Preferences
                  const Text('Fitness Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  _buildLabel('WORKOUT MODE'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _selectedWorkoutMode,
                    items: ['Home Setup', 'Commercial Gym'],
                    icon: Icons.fitness_center,
                    onChanged: (val) => setState(() => _selectedWorkoutMode = val!),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLabel('DIET PREFERENCE'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _selectedDietType,
                    items: ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Keto', 'Paleo'],
                    icon: Icons.restaurant,
                    onChanged: (val) => setState(() => _selectedDietType = val!),
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

  Widget _buildProfileImage(String photoUrl) {
    if (_isUploadingPhoto && _localPhotoPath != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(_localPhotoPath!), fit: BoxFit.cover),
          Container(
            color: Colors.black54,
            child: const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(color: AppTheme.sunsetOrange, strokeWidth: 2),
              ),
            ),
          ),
        ],
      );
    }

    if (_localPhotoPath != null) {
      return Image.file(File(_localPhotoPath!), fit: BoxFit.cover);
    }

    if (photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: AppTheme.sunsetOrange, strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, color: AppTheme.sunsetOrange, size: 48);
        },
      );
    }

    return const Icon(Icons.person, color: AppTheme.sunsetOrange, size: 48);
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

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.sunsetOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: AppTheme.surface,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
                items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
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
