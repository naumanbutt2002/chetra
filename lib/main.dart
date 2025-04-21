import 'package:chetra/bottomnavbar.dart';
import 'package:chetra/homescreen.dart';
import 'package:chetra/settings.dart';
import 'package:chetra/welcome_screen.dart';
import 'package:chetra/friends_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load .env file
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase başlatma hatası: $e");
  }
  runApp(const ChetraApp());
}

class ChetraApp extends StatelessWidget {
  const ChetraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chetra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/auth', // Start with the auth wrapper to check user state
      routes: {
        '/auth': (context) => const AuthWrapper(),
        '/login': (context) => WelcomeScreen(),
        '/home': (context) => const BottomNavBar(),
        '/socialfeed': (context) => const SocialFeedScreen(),
        '/friends': (context) => const FriendsListScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Firebase yüklenirken bekleme ekranı göster
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // User is logged in, navigate to home (BottomNavBar)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          });
          return const BottomNavBar();
        } else {
          // User is not logged in, navigate to login (WelcomeScreen)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
          });
          return WelcomeScreen();
        }
      },
    );
  }
}
