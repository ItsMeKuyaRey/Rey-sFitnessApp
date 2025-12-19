// lib/features/trainer/presentation/create_workout_screen.dart
// FIXED - Dialog now fully visible and working!

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Exercise {
  String name, sets, reps, weight;

  Exercise({
    required this.name,
    this.sets = "3",
    this.reps = "10",
    this.weight = "0",
  });
}

class CreateWorkoutScreen extends StatefulWidget {
  final Map<String, dynamic> clientData;
  const CreateWorkoutScreen({super.key, required this.clientData});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final List<Exercise> _exercises = [];

  String _safeParse(String input, String fallback) {
    if (input.isEmpty) return fallback;
    final num = int.tryParse(input.trim());
    return num != null && num >= 0 ? num.toString() : fallback;
  }

  void _addExercise() {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: "3");
    final repsCtrl = TextEditingController(text: "10");
    final weightCtrl = TextEditingController(text: "0");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900], // ← FIXED: Added dark background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Add Exercise",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white), // ← FIXED
                decoration: InputDecoration(
                  labelText: "Exercise Name",
                  labelStyle: const TextStyle(color: Colors.white70), // ← FIXED
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  prefixIcon: const Icon(Icons.fitness_center, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white), // ← FIXED
                      decoration: InputDecoration(
                        labelText: "Sets",
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: repsCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white), // ← FIXED
                      decoration: InputDecoration(
                        labelText: "Reps",
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white), // ← FIXED
                      decoration: InputDecoration(
                        labelText: "Weight",
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Exercise name required"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() {
                _exercises.add(Exercise(
                  name: name,
                  sets: _safeParse(setsCtrl.text, "3"),
                  reps: _safeParse(repsCtrl.text, "10"),
                  weight: _safeParse(weightCtrl.text, "0"),
                ));
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$name added!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              "Add Exercise",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWorkout() async {
    if (_nameCtrl.text.trim().isEmpty || _exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Add workout name + at least 1 exercise"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    final ref = FirebaseFirestore.instance
        .collection('trainers')
        .doc(user.uid)
        .collection('workout_templates');

    try {
      await ref.add({
        'name': _nameCtrl.text.trim(),
        'exercises': _exercises
            .map((e) => {
          'name': e.name,
          'sets': e.sets,
          'reps': e.reps,
          'weight': e.weight,
        })
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Workout saved permanently!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Save failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Workout Template"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Workout Name",
                hintText: "e.g. Push Day A, Full Body Strength",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_exercises.length} Exercise${_exercises.length == 1 ? '' : 's'}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    "Add Exercise",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _exercises.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No exercises yet",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Tap + Add Exercise to start",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey), // ← FIXED
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, i) {
                  final ex = _exercises[i];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(
                        Icons.fitness_center,
                        color: Colors.deepPurple,
                      ),
                      title: Text(
                        ex.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${ex.sets} sets × ${ex.reps} reps • ${ex.weight} kg",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            setState(() => _exercises.removeAt(i)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Save as Reusable Template",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}