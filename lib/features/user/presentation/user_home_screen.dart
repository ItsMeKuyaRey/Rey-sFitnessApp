// lib/features/user/presentation/user_home_screen.dart
// FULLY WORKING - ALL BUTTONS FUNCTIONAL + PROFILE SYNC + DARK MODE
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import 'user_workout_screen.dart';
import 'user_nutrition_screen.dart';
import 'user_progress_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String _userName = "John";
  String _userAvatar = "J";
  String? _userImagePath;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    // Auto refresh every 300ms for faster updates (was 500ms)
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      _checkForUpdates();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _userName = prefs.getString('user_name') ?? "John";
      _userAvatar = prefs.getString('user_avatar') ?? _userName[0].toUpperCase();
      _userImagePath = prefs.getString('user_profile_image');

      // Force refresh to ensure image loads
      print("🔄 Profile loaded: Name=$_userName, Image=$_userImagePath");
    });
  }

  Future<void> _checkForUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? "John";
    final avatar = prefs.getString('user_avatar') ?? name[0].toUpperCase();
    final image = prefs.getString('user_profile_image');

    // Check if anything changed
    if (_userName != name || _userAvatar != avatar || _userImagePath != image) {
      if (mounted) {
        print("✅ Update detected! Image: $image");
        setState(() {
          _userName = name;
          _userAvatar = avatar;
          _userImagePath = image;
        });
      }
    }
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () {
        // Force refresh when tapped
        _loadUserProfile();
      },
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.purple, width: 4),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
          ],
        ),
        child: ClipOval(
          child: _userImagePath != null && _userImagePath!.isNotEmpty
              ? Image.file(
            File(_userImagePath!),
            fit: BoxFit.cover,
            key: ValueKey(_userImagePath), // Force rebuild when path changes
            errorBuilder: (_, __, ___) {
              print("❌ Image load error: $_userImagePath");
              return _fallbackAvatar();
            },
          )
              : _fallbackAvatar(),
        ),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: Colors.purple,
      child: Center(
        child: Text(
          _userAvatar,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Colors.grey[800]! : Colors.grey[50]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // HEADER WITH PROFILE
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_getGreeting()} $_userName!",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Ready for your workout today?",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  _buildProfileAvatar(),
                ],
              ),

              const SizedBox(height: 32),

              // CALORIES CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 50, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "1,247",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Calories Burned This Week",
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ACTION BUTTONS ROW 1
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      "Start Workout",
                      Icons.play_circle_fill,
                      Colors.purple,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserWorkoutsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _actionButton(
                      "Scan Food",
                      Icons.qr_code_scanner,
                      Colors.green,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserNutritionScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ACTION BUTTON ROW 2
              _actionButton(
                "View Progress",
                Icons.trending_up,
                Colors.blue,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserProgressScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // TODAY'S PLAN SECTION
              Text(
                "Today's Plan",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 32,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Full Body Strength",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const Text(
                            "45 min • Strength",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserWorkoutsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // RECENT ACTIVITY SECTION
              Text(
                "Recent Activity",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 16),

              _activityTile(
                "Workout",
                "Upper body (45min session completed)",
                "2 hours ago",
                Icons.fitness_center,
                Colors.purple,
              ),
              _activityTile(
                "Nutrition",
                "Completed daily calories",
                "5 hours ago",
                Icons.restaurant_menu,
                Colors.green,
              ),
              _activityTile(
                "Trainer",
                "Sarah (Your Trainer) - Goal progress on your strength tra...",
                "Yesterday",
                Icons.message,
                Colors.blue,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
      String title,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activityTile(
      String type,
      String title,
      String time,
      IconData icon,
      Color color,
      ) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final cardColor = isDark ? Colors.grey[800]! : Colors.grey[50]!;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}