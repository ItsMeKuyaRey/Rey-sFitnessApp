// lib/features/trainer/presentation/trainer_dashboard.dart
// 🔥 VIOLET THEME + BADGE + ALL ORIGINAL FEATURES

import 'package:flutter/material.dart';
import 'package:fitnessapp/features/trainer/presentation/trainer_home_tab.dart';
import 'package:fitnessapp/features/trainer/presentation/trainer_clients_screen.dart';
import 'package:fitnessapp/features/trainer/presentation/trainer_plans_screen.dart';
import 'package:fitnessapp/features/trainer/presentation/trainer_notification.dart';
import 'package:fitnessapp/features/trainer/presentation/trainer_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// 🔥 VIOLET THEME - EXACT ADMIN MATCH
const Color primaryViolet = Color(0xFF8B5CF6);
const Color violetDark = Color(0xFF7C3AED);
const Color violetGradientStart = Color(0xFF9333EA);
const Color violetGradientEnd = Color(0xFF8B5CF6);

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({super.key});

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  int _selectedIndex = 0;
  int _unreadCount = 2;
  bool _isDarkMode = false;
  Timer? _themeTimer;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _themeTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => _checkThemeChange());
  }

  @override
  void dispose() {
    _themeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _isDarkMode = prefs.getBool('dark_mode') ?? false);
  }

  Future<void> _checkThemeChange() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getBool('dark_mode') ?? false;
    if (mounted && _isDarkMode != current) {
      setState(() => _isDarkMode = current);
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 3) _unreadCount = 0;
    });
  }

  late final List<Widget> _screens = [
    const TrainerHomeTab(),
    const TrainerClientsScreen(),
    const TrainerPlansScreen(),
    TrainerNotificationsScreen(onNotificationsRead: () => setState(() => _unreadCount = 0)),
    const TrainerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [violetGradientStart, violetGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: "Dashboard"),
            const BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: "Clients"),
            const BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), activeIcon: Icon(Icons.library_books), label: "Plans"),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text('$_unreadCount'),
                isLabelVisible: _unreadCount > 0,
                backgroundColor: Colors.red,
                child: Icon(_selectedIndex == 3 ? Icons.notifications : Icons.notifications_outlined),
              ),
              label: "Alerts",
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}