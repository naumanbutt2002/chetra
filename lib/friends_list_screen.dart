import 'package:chetra/login_screen.dart';
import 'package:chetra/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({Key? key}) : super(key: key);

  @override
  _FriendsListScreenState createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logoutUser(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchFriends() async {
    String userId = _auth.currentUser?.uid ?? '';

    if (userId.isEmpty) return [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/chetra_ikon.png',
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red);
              },
            ),
            Transform.translate(
              offset: const Offset(-25, 0),
              child: const Text(
                "Chetra",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Image.asset('assets/friend_requests.png',
                    width: 48, height: 48),
              ),
              InkWell(
                onTap: () {},
                child: Image.asset('assets/search_ikon.png',
                    width: 48, height: 48),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (String value) {
                  // Menü seçimlerine göre yönlendirme yapılabilir
                },
                color: Colors.grey[900],
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    padding: EdgeInsets.all(0),
                    height: 20,
                    value: 'profile',
                    child: Row(
                      children: [
                        Image.asset('assets/profile.png',
                            width: 40, height: 40),
                        const SizedBox(width: 2),
                        const Text('Profil',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    height: 20,
                    padding: EdgeInsets.all(0),
                    value: 'notifications',
                    child: Row(
                      children: [
                        Image.asset('assets/notifications.png',
                            width: 40, height: 40),
                        const SizedBox(width: 2),
                        const Text('Bildirimler',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    height: 20,
                    padding: EdgeInsets.all(0),
                    value: 'language',
                    child: Row(
                      children: [
                        Image.asset('assets/language.png',
                            width: 40, height: 40),
                        const SizedBox(width: 2),
                        const Text('Uygulama Dili',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    height: 20,
                    padding: EdgeInsets.all(0),
                    value: 'blocked_users',
                    child: Row(
                      children: [
                        Image.asset('assets/blocked_users.png',
                            width: 40, height: 40),
                        const SizedBox(width: 2),
                        const Text('Engellenen Kullanıcılar',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    height: 40,
                    padding:
                        EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 8),
                    value: 'settings',
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/setting.png',
                          width: 23,
                          height: 23,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 10),
                        const Text('Ayarlar',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    onTap: () {
                      logoutUser(context);
                    },
                    height: 20,
                    padding: EdgeInsets.all(0),
                    value: 'logout',
                    child: Row(
                      children: [
                        Image.asset('assets/logout.png', width: 40, height: 40),
                        const SizedBox(width: 2),
                        const Text('Çıkış Yap',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Henüz arkadaşın yok.",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          List<Map<String, dynamic>> friends = snapshot.data!;

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  backgroundImage: friends[index]['profilePicture'] != null &&
                          friends[index]['profilePicture'].toString().isNotEmpty
                      ? NetworkImage(friends[index]['profilePicture'])
                      : const AssetImage('assets/icons/profile.png')
                          as ImageProvider,
                ),
                title: Text(
                  friends[index]['username'] ?? "Bilinmeyen Kullanıcı",
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Arkadaş profiline gitme veya sohbet başlatma
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          border: const Border(top: BorderSide(color: Colors.grey)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.grey[850],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: 0,
          items: [
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  Image.asset('assets/friend_list.png', width: 50, height: 50),
                  const SizedBox(height: 4),
                  const Text(
                    "Arkadaş\nListesi",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  Image.asset('assets/chat_rooms.png', width: 50, height: 50),
                  const SizedBox(height: 4),
                  const Text(
                    "Sohbet\nOdaları",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  Image.asset('assets/recommended_contacts.png',
                      width: 50, height: 50),
                  const SizedBox(height: 4),
                  const Text(
                    "Önerilen\nKişiler",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  Image.asset('assets/invitation_mode.png',
                      width: 50, height: 50),
                  const SizedBox(height: 4),
                  const Text(
                    "Davet\nModu",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
              label: "",
            ),
          ],
        ),
      ),
    );
  }
}
