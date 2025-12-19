// lib/features/trainer/presentation/view_program_screen.dart

import 'package:flutter/material.dart';

class ViewProgramScreen extends StatelessWidget {
  final String clientName;
  const ViewProgramScreen({super.key, required this.clientName});

  final List<Map<String, dynamic>> program = const [
    {
      "day": "Monday",
      "focus": "Push",
      "exercises": ["Bench Press 4x8-10", "Incline DB Press 3x10", "Overhead Press 4x8", "Tricep Pushdowns 3x12", "Lateral Raises 4x15"]
    },
    {
      "day": "Wednesday",
      "focus": "Pull",
      "exercises": ["Deadlift 4x6-8", "Pull-Ups 4x8", "Barbell Row 3x10", "Face Pulls 3x15", "Bicep Curls 3x12"]
    },
    {
      "day": "Friday",
      "focus": "Legs",
      "exercises": ["Squat 4x8-10", "Romanian Deadlift 3x10", "Leg Press 3x12", "Leg Curls 3x15", "Calf Raises 4x20"]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$clientName's Program"), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: program.length,
        itemBuilder: (ctx, i) {
          final day = program[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(day["day"], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Chip(backgroundColor: Colors.deepPurple.withOpacity(0.2), label: Text(day["focus"], style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold))),
                  ],
                ),
                const Divider(height: 30),
                ...day["exercises"].map<Widget>((ex) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [const Icon(Icons.fitness_center, size: 20), const SizedBox(width: 12), Text(ex, style: const TextStyle(fontSize: 16))]),
                )).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}