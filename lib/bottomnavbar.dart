import 'package:chetra/createpostscreen.dart';
import 'package:chetra/explorescreen.dart';
import 'package:chetra/homescreen.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  // Define the screens for the bottom navigation bar
  static List<Widget> _screens = <Widget>[
    SocialFeedScreen(),
    ExploreScreen(),
    Center(child: Text("Chats")), // Placeholder for the third tab
    Center(child: Text("Friends")), // Placeholder for the fourth tab
    Center(child: Text("Profile")), // Placeholder for the fifth tab
  ];

  void _onItemTapped(int index) async {
    if (index == 2) {
      // Navigate to CreatePostScreen when the third icon is tapped
      print("Navigating to CreatePostScreen from BottomNavBar");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreatePostScreen()),
      );
      // After returning, switch back to SocialFeedScreen (index 0)
      setState(() {
        _selectedIndex = 0;
      });
      print("Returned to SocialFeedScreen after creating post");
    } else {
      // For other tabs, switch to the corresponding screen
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building BottomNavBar, selectedIndex: $_selectedIndex");
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 0),
          )
        ]),
        child: BottomAppBar(
          height: 60,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem("assets/bottomicon1.png", 0),
                _buildNavItem("assets/bottomicon2.png", 1),
                _buildNavItem("assets/bottomicon3.png", 2),
                _buildNavItem("assets/bottomicon4.png", 3),
                _buildNavItem("assets/bottomicon5.png", 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String icon, int index) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Image.asset(
        icon,
        height: 21,
        width: 21,
        fit: BoxFit.contain,
        color: _selectedIndex == index ? Color(0xffCF1102) : null,
      ),
    );
  }
}
