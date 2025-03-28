import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Cubits/get%20user%20cubit/get_user_cubit.dart';
import 'package:recipe_app/Main%20Classes/profile_screen.dart';
import 'package:recipe_app/Main%20Classes/upload_class.dart';
import 'package:recipe_app/constants/colors.dart';
import 'package:recipe_app/home/home.dart';

class NavBar extends StatefulWidget {
  final String? userId;
  const NavBar({super.key, this.userId});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      const Center(
          child: Text("Upload Screen", style: TextStyle(fontSize: 24))),
      const Center(child: Text("Scan Screen", style: TextStyle(fontSize: 24))),
      const Center(
          child: Text("Notifications Screen", style: TextStyle(fontSize: 24))),
      ProfileScreen(userId: widget.userId),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserCubit>().fetchUser(widget.userId);
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeUploadScreen(userId: widget.userId),
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItem(Icons.upload, "Upload", 1),
            const SizedBox(width: 48),
            _buildNavItem(Icons.notifications, "Notification", 3),
            _buildNavItem(Icons.person, "Profile", 4),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? primaryColor : Colors.grey, size: 24),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
