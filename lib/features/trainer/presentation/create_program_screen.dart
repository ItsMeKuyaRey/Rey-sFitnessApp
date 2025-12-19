// lib/features/trainer/presentation/create_program_screen.dart
// 🔥 FIXED VERSION - Saves to subcollection to match my_programs_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateProgramScreen extends StatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  State<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen> {
  final TextEditingController _programNameController = TextEditingController();
  int _selectedWeeks = 8;
  bool _isSaving = false;

  // Fake saved workouts (in real app this comes from Firestore)
  final List<String> _savedWorkouts = [
    "Push Day A",
    "Pull Day A",
    "Leg Day",
    "Full Body A",
    "Upper Power",
    "Lower Hypertrophy",
    "Push Day B",
    "Pull Day B",
  ];

  // Selected workouts for the program
  final List<String> _selectedWorkouts = [];

  @override
  void dispose() {
    _programNameController.dispose();
    super.dispose();
  }

  // 🔥 FIXED SAVE METHOD - Now saves to subcollection
  Future<void> _saveProgram() async {
    // Validation
    if (_programNameController.text.trim().isEmpty) {
      _showSnackBar("Please enter a program name", Colors.red);
      return;
    }

    if (_selectedWorkouts.isEmpty) {
      _showSnackBar("Please select at least one workout", Colors.red);
      return;
    }

    // Check authentication
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("You must be logged in to create programs", Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 🔥 CRITICAL FIX: Save to SUBCOLLECTION (matches my_programs_screen.dart)
      await FirebaseFirestore.instance
          .collection('trainers')
          .doc(user.uid)
          .collection('programs')
          .add({
        'trainerId': user.uid,
        'name': _programNameController.text.trim(),
        'weeks': _selectedWeeks,
        'workoutNames': _selectedWorkouts,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'clientCount': 0,
      });

      if (mounted) {
        _showSnackBar("✅ Program created successfully!", Colors.green);
        Navigator.pop(context, true);
      }
    } on FirebaseException catch (e) {
      debugPrint('🔥 Firebase Error: ${e.code} - ${e.message}');
      if (mounted) {
        String errorMessage = 'Failed to create program';

        switch (e.code) {
          case 'permission-denied':
            errorMessage = 'Permission denied. Check your authentication.';
            break;
          case 'unavailable':
            errorMessage = 'Network error. Check your connection.';
            break;
          case 'unauthenticated':
            errorMessage = 'You must be logged in.';
            break;
          default:
            errorMessage = e.message ?? 'Unknown error occurred';
        }

        _showSnackBar("❌ $errorMessage", Colors.red);
      }
    } catch (e) {
      debugPrint('🔥 Unexpected Error: $e');
      if (mounted) {
        _showSnackBar("❌ Unexpected error: ${e.toString()}", Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Build Training Program"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _isSaving
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ),
          )
              : TextButton.icon(
            onPressed: _saveProgram,
            icon: const Icon(Icons.check, size: 20),
            label: const Text(
              "Save",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program Name
            TextField(
              controller: _programNameController,
              enabled: !_isSaving,
              decoration: InputDecoration(
                labelText: "Program Name",
                hintText: "e.g. 12-Week Strength & Size",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.fitness_center),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 24),

            // Duration Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Duration",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$_selectedWeeks weeks",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: _selectedWeeks.toDouble(),
              min: 4,
              max: 16,
              divisions: 12,
              activeColor: Colors.deepPurple,
              label: "$_selectedWeeks weeks",
              onChanged: _isSaving ? null : (value) => setState(() => _selectedWeeks = value.round()),
            ),
            const SizedBox(height: 32),

            // Workout Library Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Choose Workouts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${_selectedWorkouts.length}/${_savedWorkouts.length}",
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Workout Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemCount: _savedWorkouts.length,
                itemBuilder: (context, index) {
                  final workout = _savedWorkouts[index];
                  final isSelected = _selectedWorkouts.contains(workout);

                  return GestureDetector(
                    onTap: _isSaving
                        ? null
                        : () {
                      setState(() {
                        if (isSelected) {
                          _selectedWorkouts.remove(workout);
                        } else {
                          _selectedWorkouts.add(workout);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple.withOpacity(0.15)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.deepPurple.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 36,
                            color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              workout,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isSelected ? Colors.deepPurple : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.deepPurple,
                                size: 22,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Selected Count Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.withOpacity(0.15),
                    Colors.deepPurple.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.checklist, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    "${_selectedWorkouts.length} workout${_selectedWorkouts.length == 1 ? '' : 's'} selected",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}