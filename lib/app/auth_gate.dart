import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';

/// AuthGate listens to Firebase auth state changes and routes accordingly.
///
/// - If the user is authenticated → populates UserProvider and shows [MainScreen].
/// - If the user is not authenticated → shows [LoginScreen].
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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
          // Auto-populate user provider
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final provider = Provider.of<UserProvider>(context, listen: false);
            // Set basic info from Firebase Auth
            provider.updateAccount(
              user.displayName ?? '',
              user.email ?? '',
            );
            if (user.photoURL != null && user.photoURL!.isNotEmpty) {
              provider.setProfilePhotoUrl(user.photoURL!);
            }
            // Load additional data from Firestore
            await provider.loadUserProfile(user.uid);
            // Load local data
            await provider.loadWeightLogsLocally();
            await provider.loadTrackerDataLocally();
            await provider.loadPlanLocally();
          });

          return const MainScreen();
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}
