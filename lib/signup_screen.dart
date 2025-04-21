
import 'package:chetra/bottomnavbar.dart';
import 'package:chetra/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'friends_list_screen.dart'; // Arkadaş listesi ekranını ekliyoruz
import 'package:chetra/database_service.dart'; // Adjust the path as needed
import 'dart:io';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedGender = "Erkek";
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  File? _selectedProfilePicture;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedProfilePicture = File(pickedFile.path);
      });
    }
  }
  Future<void> _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String username = _usernameController.text.trim();
    String ageText = _ageController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        ageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tüm alanları doldurun!")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifreler uyuşmuyor!")),
      );
      return;
    }

    int? age = int.tryParse(ageText);
    if (age == null || age < 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Kayıt olmak için en az 13 yaşında olmalısınız!")),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        DatabaseService databaseService = DatabaseService();
        String userId = userCredential.user!.uid;
        String? profilePictureUrl;

        // Upload profile picture to Cloudflare R2 if selected
        if (_selectedProfilePicture != null) {
          String fileName =
              '${userId}_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
          profilePictureUrl = await databaseService.uploadMediaToR2(
              _selectedProfilePicture!, fileName);
        }

        // Save user profile to Firestore
        await databaseService.saveUserProfile(
          username: username,
          location: 'Da Nang, Vietnam',
          bio:
              'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.',
          profilePicture: profilePictureUrl,
        );

        // For story highlights, we'll assume you have placeholder images in your assets
        // For this example, you need to add the images to your project assets and update pubspec.yaml
        // Example: assets/friends.jpg, assets/design.jpg, assets/sport.jpg
        List<String> highlightLabels = ['Friends', 'Design', 'Sport'];
        List<String> highlightImagePaths = [
          'assets/friends.png',
          'assets/design.png',
          'assets/sport.png',
        ];

        for (int i = 0; i < highlightLabels.length; i++) {
          String label = highlightLabels[i];
          String imagePath = highlightImagePaths[i];
          File imageFile = File(imagePath);
          String fileName =
              '${userId}_${label.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          String? imageUrl =
              await databaseService.uploadMediaToR2(imageFile, fileName);
          if (imageUrl != null) {
            // Store only the file name in Firestore
            String fileNameOnly = fileName;
            await databaseService.saveStoryHighlight(
              userId: userId,
              label: label,
              imageUrl: fileNameOnly, // Store the file name, not the full URL
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kayıt başarılı!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kayıt başarısız: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Kayıt Ol"),
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
                        : null,
                  ),
                  child: _selectedProfilePicture == null
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
            const Text("Kullanıcı Adı",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: "Kullanıcı adınızı girin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("E-Posta",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: "E-posta adresinizi girin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Şifre", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: "Şifrenizi girin",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Şifre Tekrar",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Şifrenizi tekrar girin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Cinsiyet",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: <String>["Erkek", "Kadın"].map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Yaş", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Yaşınızı girin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                ),
                const Text("Beni Hatırla"),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _signUp, // Kayıt fonksiyonunu çağır
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text("Kayıt Ol"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
