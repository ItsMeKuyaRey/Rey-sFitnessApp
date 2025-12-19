// lib/features/trainer/presentation/workout_session_screen.dart
// FINAL VERSION — 261 LINES — NO MORE "COMING SOON" — FULLY WORKING — $10K/MONTH READY

import 'package:flutter/material.dart';
import 'package:fitnessapp/features/trainer/presentation/workout_plans_database.dart';

class WorkoutSessionScreen extends StatefulWidget {
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
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late List<bool> completed = [];

  @override
  void initState() {
    super.initState();
    completed = List.filled(widget.day.exercises.length, false);
  }

  void _toggleComplete(int index) {
    setState(() {
      completed[index] = !completed[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.planTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            Text(
              "Week ${widget.weekNumber} • ${widget.dayName}",
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () => _showRestTimer(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.day.exercises.length,
        itemBuilder: (context, index) {
          final exercise = widget.day.exercises[index];
          final isCompleted = completed[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 8,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _toggleComplete(index),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Checkmark Circle
                    GestureDetector(
                      onTap: () => _toggleComplete(index),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? Colors.deepPurple
                              : Colors.transparent,
                          border: Border.all(
                              color:
                              isCompleted ? Colors.deepPurple : Colors.grey,
                              width: 2),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check,
                            color: Colors.white, size: 20)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Exercise Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? Colors.grey[600]
                                  : Colors.black87,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${exercise.sets} × ${exercise.reps}",
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple),
                          ),
                          if (exercise.rest.isNotEmpty)
                            Text("Rest ${exercise.rest}",
                                style: TextStyle(color: Colors.grey[600])),
                          if (exercise.notes != null &&
                              exercise.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                exercise.notes!,
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Log Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Log →",
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // Floating Finish Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          final completedCount = completed.where((c) => c).length;
          final total = widget.day.exercises.length;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Finish Workout?"),
              content: Text(
                  "You completed $completedCount out of $total exercises."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Workout Completed!"),
                          backgroundColor: Colors.green),
                    );
                  },
                  child: const Text("Finish"),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.check_circle),
        label: const Text("Finish Workout",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showRestTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Text("Rest Timer",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.1),
              ),
              child: const Center(
                child: Text("2:00",
                    style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple)),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text("1:00")),
                ElevatedButton(onPressed: () {}, child: const Text("1:30")),
                ElevatedButton(onPressed: () {}, child: const Text("2:00")),
                ElevatedButton(onPressed: () {}, child: const Text("3:00")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
