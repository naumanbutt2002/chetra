import 'package:chetra/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  File? _selectedProfilePicture;
  String? _currentProfilePictureUrl;
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
          _usernameController.text = userProfile['username'] ?? '';
          _locationController.text = userProfile['location'] ?? '';
          _bioController.text = userProfile['bio'] ?? '';
          _currentProfilePictureUrl = userProfile['profilePicture'];
        });
      }
    } catch (e) {
      print("Error loading user profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e")),
      );
    }
  }

  Future<void> _pickProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedProfilePicture = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (userId == null) return;

    try {
      String? profilePictureUrl = _currentProfilePictureUrl;

      // Upload new profile picture if selected
      if (_selectedProfilePicture != null) {
        String fileName =
            '${userId}_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        profilePictureUrl = await _databaseService.uploadMediaToR2(
            _selectedProfilePicture!, fileName);
        if (profilePictureUrl == null) {
          print("Failed to upload new profile picture");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload profile picture")),
          );
          return;
        }
      }

      // Save updated profile to Firestore
      await _databaseService.saveUserProfile(
        username: _usernameController.text.trim(),
        location: _locationController.text.trim(),
        bio: _bioController.text.trim(),
        profilePicture: profilePictureUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );

      // Navigate back to SettingsScreen
      Navigator.pop(context);
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: $e")),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickProfilePicture,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 1),
                    image: _selectedProfilePicture != null
                        ? DecorationImage(
                            image: FileImage(_selectedProfilePicture!),
                            fit: BoxFit.cover,
                          )
                        : _currentProfilePictureUrl != null &&
                                _currentProfilePictureUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_currentProfilePictureUrl!),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print(
                                      "Error loading profile picture: $exception");
                                },
                              )
                            : null,
                  ),
                  child: _selectedProfilePicture == null &&
                          (_currentProfilePictureUrl == null ||
                              _currentProfilePictureUrl!.isEmpty)
                      ? const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Username",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: "Enter your username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Location",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: "Enter your location",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Bio", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Enter your bio",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}