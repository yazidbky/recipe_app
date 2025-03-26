import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Cubits/get%20user%20cubit/get_user_cubit.dart';
import 'package:recipe_app/Main%20Classes/profile_screen.dart';
import 'package:recipe_app/Main%20Classes/upload_class.dart';
import 'package:recipe_app/home/home.dart';

class NavBar extends StatefulWidget {
  final String userId;
  const NavBar({super.key, required this.userId});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  late List<Widget> _screens; // Cache the screens list

  @override
  void initState() {
    super.initState();
    // Initialize screens once
    _screens = [
      HomeScreen(),
      const Center(
          child: Text("Upload Screen", style: TextStyle(fontSize: 24))),
      const Center(child: Text("Scan Screen", style: TextStyle(fontSize: 24))),
      const Center(
          child: Text("Notifications Screen", style: TextStyle(fontSize: 24))),
      ProfileScreen(userId: widget.userId),
    ];

    // Fetch user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserCubit>().fetchUser(widget.userId);
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Handle upload screen navigation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeUploadScreen(userId: widget.userId),
        ),
      );
      return;
    }

    if (index == 2) {
      // Handle scan button click
      print("Scan Button Pressed");
      // TODO: Implement scan screen navigation
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
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(Icons.notifications, "Notification", 3),
            _buildNavItem(Icons.person, "Profile", 4),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: Colors.green,
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
          Icon(icon, color: isSelected ? Colors.green : Colors.grey, size: 24),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
