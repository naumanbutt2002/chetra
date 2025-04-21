import 'package:chetra/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});
  final TextEditingController forogtusernameController =
      TextEditingController();
  final TextEditingController forgotemailController = TextEditingController();

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: forgotemailController.text.trim());
      Get.snackbar(
        'Şifre Sıfırlama',
        'Şifre sıfırlama e-postası gönderildi!',
        snackPosition: SnackPosition.TOP,
      );
      Future.delayed(Duration(seconds: 2), () {
        Get.offAll(LoginScreen());
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text("Parolanızı mı unuttunuz"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/chetraicon.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 20),
              const Text("Kullanıcı Adı",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: forogtusernameController,
                decoration: const InputDecoration(
                  hintText: "Kullanıcı adınızı girin",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "E-Posta",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: forgotemailController,
                decoration: const InputDecoration(
                  hintText: "E-posta adresinizi girin",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (forgotemailController.text.isNotEmpty) {
                      resetPassword();
                    } else {
                      Get.snackbar(
                        backgroundColor: Colors.black,
                        colorText: Colors.white,
                        'Error',
                        'Please enter your email address.',
                        snackPosition: SnackPosition.TOP,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text("şifremi yenile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
