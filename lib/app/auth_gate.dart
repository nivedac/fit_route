import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';

/// AuthGate listens to Firebase auth state changes and routes accordingly.
///
/// - If the user is authenticated → populates UserProvider and shows [MainScreen].
/// - If the user is not authenticated → clears all data and shows [LoginScreen].
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  /// Track the currently loaded user ID to detect user switches
  String? _loadedUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading indicator while determining auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          final user = snapshot.data!;

          // Only load data if this is a NEW user or first load
          if (_loadedUid != user.uid) {
            _loadedUid = user.uid;
            debugPrint('🔑 AuthGate: User authenticated → ${user.uid}');

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              final provider = Provider.of<UserProvider>(context, listen: false);

              // Clear any lingering previous user data FIRST
              if (provider.uid != null && provider.uid != user.uid) {
                debugPrint('🔀 AuthGate: Switching user ${provider.uid} → ${user.uid}');
                await provider.clearData();
              }

              // Set basic info from Firebase Auth
              provider.updateAccount(
                user.displayName ?? '',
                user.email ?? '',
              );
              if (user.photoURL != null && user.photoURL!.isNotEmpty) {
                provider.setProfilePhotoUrl(user.photoURL!);
              }

              // Load THIS USER's data from Firestore
              await provider.loadUserProfile(user.uid);

              // Load THIS USER's local data (keyed by uid)
              await provider.loadWeightLogsLocally();
              await provider.loadTrackerDataLocally();
              await provider.loadPlanLocally();

              debugPrint('✅ AuthGate: All data loaded for ${user.uid}');
            });
          }

          return const MainScreen();
        }

        // User is NOT logged in → clear everything
        if (_loadedUid != null) {
          _loadedUid = null;
          debugPrint('🚪 AuthGate: User logged out → clearing all data');

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            final provider = Provider.of<UserProvider>(context, listen: false);
            await provider.clearData();
          });
        }

        return const LoginScreen();
      },
    );
  }
}
