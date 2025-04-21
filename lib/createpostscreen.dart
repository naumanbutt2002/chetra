import 'package:chetra/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _hashtagsController = TextEditingController();
  bool _isLoading = false;
  String? _profilePictureUrl; // To store the user's profile picture URL
  String? _userLocation; // To store the user's location

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch the user's profile when the screen loads
  }

  Future<void> _fetchUserProfile() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      Map<String, dynamic>? userProfile =
          await _databaseService.getUserProfile(userId);
      if (userProfile != null) {
        setState(() {
          // Fetch profile picture URL if it exists
          if (userProfile['profilePicture'] != null &&
              userProfile['profilePicture'].isNotEmpty) {
            _profilePictureUrl = userProfile['profilePicture'];
          }
          // Fetch location if it exists, otherwise set a default value
          _userLocation = userProfile['location'] ?? "Unknown Location";
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      setState(() {
        _userLocation = "Unknown Location"; // Fallback in case of error
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String fileName =
          '${userId}_post_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String? mediaUrl =
          await _databaseService.uploadMediaToR2(_selectedImage!, fileName);
      if (mediaUrl == null) {
        print("Failed to upload post image");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload post image")),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _databaseService.createPost(
        userId: userId,
        mediaUrl: fileName,
        content: _contentController.text.trim(),
        hashtags: _hashtagsController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully!")),
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        print("Popping back from CreatePostScreen");
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Error creating post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating post: $e")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _hashtagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      "assets/backicon.png",
                      height: 28,
                      width: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Create a Post",
                        style: TextStyle(
                          color: Color(0xff141414),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                      : GestureDetector(
                          onTap: _createPost,
                          child: Container(
                            height: 29,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Center(
                              child: Text(
                                "Post",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 60),
              const Text(
                "Share your thoughts.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff141414),
                ),
              ),
              const SizedBox(height: 13),
              Container(
                padding: const EdgeInsets.only(left: 19, top: 17, bottom: 36),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xff616161)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: _profilePictureUrl != null
                              ? NetworkImage(_profilePictureUrl!)
                              : null,
                          child: _profilePictureUrl == null
                              ? const Icon(Icons.person, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _auth.currentUser?.email?.split('@')[0] ?? "User",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Image.asset(
                                  "assets/worldicon.png",
                                  height: 7.3,
                                  width: 7.3,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _userLocation ?? "Loading...",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Write something....",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff141414),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _hashtagsController,
                      maxLines: 1,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Add hashtags (e.g., #StudyBreak #Fun)",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff141414),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/cameraicon.png",
                      height: 22,
                      width: 22,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Upload photo",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xff141414),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(
                    _selectedImage!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
