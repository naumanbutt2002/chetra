import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı kaydı
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException - Kayıt hatası: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("Bilinmeyen hata - Kayıt hatası: $e");
      return null;
    }
  }

  // Kullanıcı girişi
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException - Giriş hatası: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("Bilinmeyen hata - Giriş hatası: $e");
      return null;
    }
  }

  // Kullanıcı çıkışı
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Çıkış hatası: $e");
    }
  }

  // Mevcut kullanıcıyı al
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
