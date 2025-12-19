// lib/features/user/presentation/user_dashboard.dart
// COMPLETE DASHBOARD WITH ALL NAVIGATION WORKING - FIXED
import 'package:flutter/material.dart';
import 'user_home_screen.dart';
import 'user_workout_screen.dart';
import 'user_nutrition_screen.dart';
import 'user_progress_screen.dart';
import 'user_profile_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  // ✅ FIX: Remove 'const' keyword - these are StatefulWidgets
  static final List<Widget> _screens = <Widget>[
    const UserHomeScreen(),
    const UserWorkoutsScreen(),
    const UserNutritionScreen(),  // ✅ This is now properly recognized
    const UserProgressScreen(),
    const UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.deepPurple,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 26),
              activeIcon: Icon(Icons.home, size: 28),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined, size: 26),
              activeIcon: Icon(Icons.fitness_center, size: 28),
              label: "Workouts",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined, size: 26),
              activeIcon: Icon(Icons.restaurant_menu, size: 28),
              label: "Nutrition",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_outlined, size: 26),
              activeIcon: Icon(Icons.show_chart, size: 28),
              label: "Progress",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 26),
              activeIcon: Icon(Icons.person, size: 28),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}