// lib/features/user/presentation/user_workout_screen.dart
// WITH DARK MODE SUPPORT!
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import 'workout_player_screen.dart';

class UserWorkoutsScreen extends StatelessWidget {
  const UserWorkoutsScreen({super.key});

  static final List<Map<String, dynamic>> workouts = [
    {
      "title": "Full Body Strength",
      "trainer": "Trainer Alex Johnson",
      "type": "Strength",
      "duration": "45 min",
      "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=800&q=80",
      "exercises": [
        {
          "name": "Barbell Squats",
          "reps": 10,
          "sets": 3,
          "animation": "assets/videos/squat.mp4",
          "animationType": "video"
        },
        {
          "name": "Bench Press",
          "reps": 8,
          "sets": 3,
          "animation": "assets/videos/bench_press.mp4",
          "animationType": "video"
        },
        {
          "name": "Pull-Ups",
          "reps": 8,
          "sets": 3,
          "animation": "assets/videos/pull_ups.mp4",
          "animationType": "video"
        },
        {
          "name": "Shoulder Press",
          "reps": 10,
          "sets": 3,
          "animation": "assets/videos/ShoulderPressed.mp4",
          "animationType": "video"
        },
        {
          "name": "Deadlifts",
          "reps": 6,
          "sets": 3,
          "animation": "assets/videos/deadlifts.mp4",
          "animationType": "video"
        },
      ],
    },
    {
      "title": "HIIT Cardio Blast",
      "trainer": "Trainer Sarah Miller",
      "type": "Cardio",
      "duration": "30 min",
      "image": "https://images.pexels.com/photos/3757375/pexels-photo-3757375.jpeg?auto=compress&cs=tinysrgb&w=800",
      "exercises": [
        {
          "name": "Jumping Jacks",
          "duration": 30,
          "rest": 15,
          "animation": "assets/videos/jumping_jacks.mp4",
          "animationType": "video"
        },
        {
          "name": "High Knees",
          "duration": 30,
          "rest": 15,
          "animation": "assets/videos/high_knees.mp4",
          "animationType": "video"
        },
        {
          "name": "Burpees",
          "duration": 30,
          "rest": 15,
          "animation": "assets/videos/burpees.mp4",
          "animationType": "video"
        },
        {
          "name": "Mountain Climbers",
          "duration": 30,
          "rest": 15,
          "animation": "assets/videos/mountain_climbers.mp4",
          "animationType": "video"
        },
        {
          "name": "Jump Squats",
          "duration": 30,
          "rest": 15,
          "animation": "assets/videos/jump_squats.mp4",
          "animationType": "video"
        },
        {
          "name": "Plank Jacks",
          "duration": 30,
          "rest": 15,
          "animation": "assets/videos/plank_jacks.mp4",
          "animationType": "video"
        },
      ],
    },
    {
      "title": "Morning Yoga Flow",
      "trainer": "Trainer Emma Davis",
      "type": "Yoga",
      "duration": "25 min",
      "image": "https://images.unsplash.com/photo-1549570652-97324981a6fd?auto=format&fit=crop&w=800&q=80",
      "exercises": [
        {
          "name": "Child's Pose",
          "hold": 30,
          "animation": "assets/videos/childs_pose.mp4",
          "animationType": "video"
        },
        {
          "name": "Downward Dog",
          "hold": 30,
          "animation": "assets/videos/downward_dog.mp4",
          "animationType": "video"
        },
        {
          "name": "Warrior I",
          "hold": 30,
          "animation": "assets/videos/warrior_one.mp4",
          "animationType": "video"
        },
        {
          "name": "Cat-Cow",
          "hold": 30,
          "animation": "assets/videos/cat_cow.mp4",
          "animationType": "video"
        },
        {
          "name": "Seated Forward Bend",
          "hold": 30,
          "animation": "assets/videos/forward_bend.mp4",
          "animationType": "video"
        },
        {
          "name": "Savasana",
          "hold": 60,
          "animation": "assets/videos/savasana.mp4",
          "animationType": "video"
        },
      ],
    },
    {
      "title": "Lower Body Power",
      "trainer": "Trainer Mike Chen",
      "type": "Strength",
      "duration": "50 min",
      "image": "https://images.pexels.com/photos/1552101/pexels-photo-1552101.jpeg?w=800&q=80",
      "exercises": [
        {
          "name": "Box Jumps",
          "reps": 10,
          "sets": 3,
          "animation": "assets/videos/box_jumps.mp4",
          "animationType": "video"
        },
        {
          "name": "Romanian Deadlifts",
          "reps": 8,
          "sets": 3,
          "animation": "assets/videos/romanian_deadlifts.mp4",
          "animationType": "video"
        },
        {
          "name": "Barbell Squats",
          "reps": 8,
          "sets": 3,
          "animation": "assets/videos/barbell_squats.mp4",
          "animationType": "video"
        },
        {
          "name": "Lunges",
          "reps": 10,
          "sets": 3,
          "animation": "assets/videos/lunges.mp4",
          "animationType": "video"
        },
        {
          "name": "Kettlebell Swings",
          "reps": 15,
          "sets": 3,
          "animation": "assets/videos/kettlebell_swings.mp4",
          "animationType": "video"
        },
      ],
    },
  ];

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
        leading: const BackButton(),
        title: const Text(
          "Workouts",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.notifications_outlined),
          SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final w = workouts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    w["image"] as String,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.red[50],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w["title"] as String,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        w["trainer"] as String,
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _tag(w["type"] as String, isDark),
                          const SizedBox(width: 12),
                          _tag(w["duration"] as String, isDark),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutPlayerScreen(workout: w),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Start Workout",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tag(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}