// lib/features/user/presentation/user_progress_screen.dart
// FULLY CONNECTED TO PROFILE + DARK MODE SUPPORT
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import 'detailed_progress_history_screen.dart';

class UserProgressScreen extends StatefulWidget {
  const UserProgressScreen({super.key});

  @override
  State<UserProgressScreen> createState() => _UserProgressScreenState();
}

class _UserProgressScreenState extends State<UserProgressScreen> {
  String _currentWeight = "68";
  String _goalWeight = "60";
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _currentWeight = prefs.getString('user_current_weight') ?? "68";
      _goalWeight = prefs.getString('user_goal_weight') ?? "60";
      _profileImagePath = prefs.getString('user_profile_image');
    });
  }

  double get _progressPercentage {
    final current = double.tryParse(_currentWeight) ?? 68;
    final goal = double.tryParse(_goalWeight) ?? 60;
    final initial = 90.0; // Starting weight (you can make this dynamic too)

    if (initial <= goal) return 1.0;
    return ((initial - current) / (initial - goal)).clamp(0.0, 1.0);
  }

  double get _weightLost {
    const initial = 90.0;
    final current = double.tryParse(_currentWeight) ?? 68;
    return initial - current;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = isDark ? Colors.grey[900]! : Colors.grey[50]!;
    final cardColor = isDark ? Colors.grey[800]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Progress",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DetailedProgressHistoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // WEIGHT PROGRESS CARD - CONNECTED TO PROFILE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weight Progress",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statColumn("Current", "$_currentWeight kg", Colors.white),
                      _statColumn("Goal", "$_goalWeight kg", Colors.white70),
                      _statColumn("Lost", "${_weightLost.toStringAsFixed(1)} kg", Colors.greenAccent),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progressPercentage,
                      minHeight: 12,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(_progressPercentage * 100).toStringAsFixed(0)}% to goal",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // STATS GRID
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Workouts",
                    "87",
                    Icons.fitness_center,
                    Colors.orange,
                    cardColor,
                    textColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    "Streak",
                    "7 days",
                    Icons.local_fire_department,
                    Colors.red,
                    cardColor,
                    textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Calories",
                    "18,247",
                    Icons.local_fire_department,
                    Colors.deepOrange,
                    cardColor,
                    textColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    "Body Fat",
                    "19%",
                    Icons.trending_down,
                    Colors.green,
                    cardColor,
                    textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // PROFILE PROGRESS PHOTO
            if (_profileImagePath != null && _profileImagePath!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Progress Photo",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(_profileImagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Last updated: Today",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                ],
              ),

            // RECENT ACHIEVEMENTS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Achievements",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DetailedProgressHistoryScreen(),
                      ),
                    );
                  },
                  child: const Text("View All"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _achievementTile(
              "7-Day Streak",
              "Completed workouts for 7 days in a row",
              Icons.whatshot,
              Colors.orange,
              cardColor,
              textColor,
            ),
            _achievementTile(
              "${_weightLost.toStringAsFixed(0)}kg Lost",
              "Lost weight since starting your journey",
              Icons.emoji_events,
              Colors.amber,
              cardColor,
              textColor,
            ),
            _achievementTile(
              "PR: Bench Press",
              "New personal record: 100kg",
              Icons.fitness_center,
              Colors.purple,
              cardColor,
              textColor,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementTile(String title, String subtitle, IconData icon, Color color, Color cardColor, Color textColor) {
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}