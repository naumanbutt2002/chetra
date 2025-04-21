import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart'; // Login ekranını ekledik

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Chetra'ya Hoşgeldin",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Image.asset(
                      'assets/chetraicon.png',
                      width: 100,
                      height: 100,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: Size(200, 50),
                      ),
                      child: Text("Kayıt Ol"),
                    ),
                    SizedBox(height: 10),
                    Text("veya", style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(), // Login ekranına git
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.black),
                        minimumSize: Size(200, 50),
                      ),
                      child: Text("Giriş Yap"),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                "Version 1.0",
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
