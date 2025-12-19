// lib/features/trainer/presentation/program_viewer_screen.dart
// 🔥 FIXED "No element" ERROR + USES planMap DIRECTLY
import 'package:flutter/material.dart';

class Day {
  final String name;
  final List<Exercise> exercises;
  Day({required this.name, required this.exercises});
}

class Exercise {
  final String name;
  final String sets;
  final String reps;
  Exercise({required this.name, required this.sets, required this.reps});
}

// Placeholder workout screen
class WorkoutSessionScreen extends StatelessWidget {
  final Day day;
  final int weekNumber;
  final String dayName;
  final String planTitle;
  const WorkoutSessionScreen({
    super.key,
    required this.day,
    required this.weekNumber,
    required this.dayName,
    required this.planTitle,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("$planTitle - $dayName")),
    body: Center(child: Text("Workout Session Coming Soon")),
  );
}

class ProgramViewerScreen extends StatelessWidget {
  final Map<String, dynamic> planMap;
  const ProgramViewerScreen({super.key, required this.planMap});

  // 🔥 FIXED: Use planMap directly - NO DATABASE DEPENDENCY
  Map<String, dynamic> get plan {
    return {
      "title": planMap["title"] ?? "Untitled Program",
      "duration": planMap["duration"] ?? "8 weeks",
      "weeks": _safeWeeks(planMap["weeks"] ?? []),
      "imagePath": planMap["imagePath"] ?? "https://via.placeholder.com/400x280/6B46C1/FFFFFF?text=Program",
    };
  }

  // 🔥 BULLETPROOF WEEKS DATA
  List<Map<String, dynamic>> _safeWeeks(dynamic weeksData) {
    List<Map<String, dynamic>> safeWeeks = [];

    if (weeksData is List && weeksData.isNotEmpty) {
      for (int i = 0; i < weeksData.length; i++) {
        try {
          final week = weeksData[i];
          if (week is Map<String, dynamic>) {
            safeWeeks.add({
              'number': (week['week'] ?? i + 1) as int,
              'days': _safeDays(week['workouts'] ?? []),
            });
          }
        } catch (e) {
          safeWeeks.add({
            'number': i + 1,
            'days': [],
          });
        }
      }
    }

    // Ensure at least 1 week with days
    if (safeWeeks.isEmpty) {
      safeWeeks.add({
        'number': 1,
        'days': [
          {'name': 'Day 1', 'exercises': []},
        ],
      });
    }

    return safeWeeks;
  }

  // 🔥 SAFE DAYS CONVERSION
  List<Map<String, dynamic>> _safeDays(dynamic workoutsData) {
    List<Map<String, dynamic>> safeDays = [];

    if (workoutsData is List && workoutsData.isNotEmpty) {
      // Group workouts into days (simple: 1 day per workout group)
      for (int i = 0; i < workoutsData.length; i += 3) { // 3 workouts per day
        final dayWorkouts = workoutsData.sublist(
          i,
          i + 3 > workoutsData.length ? workoutsData.length : i + 3,
        );
        safeDays.add({
          'name': 'Day ${safeDays.length + 1}',
          'exercises': _safeExercises(dayWorkouts),
        });
      }
    }

    if (safeDays.isEmpty) {
      safeDays.add({
        'name': 'Day 1',
        'exercises': [
          {'name': 'Warm Up', 'sets': '2', 'reps': '10'},
          {'name': 'Workout', 'sets': '3', 'reps': '12'},
        ],
      });
    }

    return safeDays;
  }

  // 🔥 SAFE EXERCISES
  List<Map<String, dynamic>> _safeExercises(dynamic workoutData) {
    List<Map<String, dynamic>> safeExercises = [];

    if (workoutData is List && workoutData.isNotEmpty) {
      for (final workout in workoutData) {
        if (workout is Map<String, dynamic>) {
          safeExercises.add({
            'name': workout['name'] ?? 'Exercise',
            'sets': workout['sets'] ?? '3',
            'reps': workout['reps'] ?? '12',
          });
        }
      }
    }

    if (safeExercises.isEmpty) {
      safeExercises.addAll([
        {'name': 'Sample Exercise 1', 'sets': '3', 'reps': '12'},
        {'name': 'Sample Exercise 2', 'sets': '3', 'reps': '10'},
      ]);
    }

    return safeExercises;
  }

  void _openWorkoutSession(BuildContext context, Map<String, dynamic> day,
      int weekNumber, String dayName) {
    final exercises = day['exercises'] as List<Map<String, dynamic>>;
    final workoutDay = Day(
      name: dayName,
      exercises: exercises.map((e) => Exercise(
        name: e['name'] ?? '',
        sets: e['sets'] ?? '',
        reps: e['reps'] ?? '',
      )).toList(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSessionScreen(
          day: workoutDay,
          weekNumber: weekNumber,
          dayName: dayName,
          planTitle: plan["title"],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final realPlan = plan;
    final weeks = realPlan["weeks"] as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          realPlan["title"],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(24),
                  image: DecorationImage(
                    image: NetworkImage(realPlan["imagePath"]),
                    fit: BoxFit.cover,
                    onError: (_, __) => null,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 80,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Text(
                        realPlan["title"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              realPlan["title"],
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  realPlan["duration"],
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              "Program Structure",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 🔥 ALL WEEKS & DAYS - BULLETPROOF
            ...weeks.map((week) {
              final weekNumber = week['number'] as int;
              final days = week['days'] as List<Map<String, dynamic>>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Week $weekNumber",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  ...days.map((day) {
                    final dayIndex = days.indexOf(day) + 1;
                    final exercises = day['exercises'] as List;
                    final exerciseCount = exercises.length;
                    final estimatedMins = (exerciseCount * 8).clamp(20, 90);

                    String dayName = "Day $dayIndex";
                    final lowerNames = exercises
                        .map((e) => (e['name'] ?? '').toString().toLowerCase())
                        .toList();

                    if (lowerNames.any((n) =>
                    n.contains("squat") ||
                        n.contains("deadlift") ||
                        n.contains("lunge"))) {
                      dayName = "Lower Body";
                    } else if (lowerNames.any((n) =>
                    n.contains("bench") ||
                        n.contains("press"))) {
                      dayName = "Push";
                    } else if (lowerNames.any((n) =>
                    n.contains("pull") ||
                        n.contains("row"))) {
                      dayName = "Pull";
                    }

                    return InkWell(
                      onTap: () => _openWorkoutSession(
                          context, day, weekNumber, dayName),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.deepPurple,
                              child: Text(
                                "${weekNumber}${String.fromCharCode(64 + dayIndex)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dayName,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$exerciseCount exercises • ~$estimatedMins min",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.deepPurple,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),

            const SizedBox(height: 40),
            // Back Button
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text(
                "Back to Plans",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}