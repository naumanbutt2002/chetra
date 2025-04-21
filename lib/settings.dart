import 'package:chetra/database_service.dart';
import 'package:chetra/profile_edit_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _username;
  String? _location;
  String? _profilePictureUrl;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (userId == null) return;

    try {
      Map<String, dynamic>? userProfile =
          await _databaseService.getUserProfile(userId!);
      if (userProfile != null) {
        setState(() {
          _username = userProfile['username'] ?? '';
          _location = userProfile['location'] ?? 'Unknown Location';
          _profilePictureUrl = userProfile['profilePicture'];
        });
      }
    } catch (e) {
      print("Error loading user profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e")),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      // Navigate to the login screen or initial screen after logout
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print("Error logging out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        // title: const Text("Setting"),
        actions: [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: _profilePictureUrl != null
                        ? NetworkImage(_profilePictureUrl!)
                        : null,
                    child: _profilePictureUrl == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Image.asset(
                            "assets/worldicon.png",
                            height: 16,
                            width: 16,
                            fit: BoxFit.contain,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _location ?? 'Loading...',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Options List
              ListTile(
                leading: const Icon(Icons.person, color: Colors.black),
                title: const Text(
                  'Profile',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileEditScreen()),
                  ).then((_) {
                    // Reload user profile when returning from ProfileEditScreen
                    _loadUserProfile();
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.black),
                title: const Text(
                  'Application Language',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                onTap: () {
                  // Hardcoded, no action
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.black),
                title: const Text(
                  'Block Users',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                onTap: () {
                  // Hardcoded, no action
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark, color: Colors.black),
                title: const Text(
                  'Recorded',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                onTap: () {
                  // Hardcoded, no action
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.black),
                title: const Text(
                  'Account Privacy',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                onTap: () {
                  // Hardcoded, no action
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
