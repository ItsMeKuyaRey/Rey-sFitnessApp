// lib/features/trainer/presentation/workout_library_screen.dart
// FINAL x1000000 — WITH DELETE BUTTON + CONFIRMATION + REAL-TIME UPDATE

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WorkoutLibraryScreen extends StatelessWidget {
  const WorkoutLibraryScreen({super.key});

  // DELETE FUNCTION WITH CONFIRMATION
  Future<void> _deleteWorkout(BuildContext context, DocumentSnapshot doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Workout?"),
        content: Text("Remove \"${doc['name']}\" permanently?\nThis cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await doc.reference.delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("\"${doc['name']}\" deleted"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Workout Templates"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trainers')
            .doc(userId)
            .collection('workout_templates')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading templates"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text("No workout templates yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const Text("Create one from Dashboard → Create Workout"),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back to Dashboard"),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? "Unnamed Workout";
              final exerciseList = data['exercises'] as List<dynamic>? ?? [];
              final exerciseCount = exerciseList.length;

              return Dismissible(
                key: ValueKey(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_forever, color: Colors.white, size: 32),
                ),
                confirmDismiss: (_) => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Workout?"),
                    content: Text("Remove \"$name\" forever?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                ),
                onDismissed: (_) => doc.reference.delete(),
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.fitness_center, color: Colors.white),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text("$exerciseCount exercise${exerciseCount == 1 ? '' : 's'}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteWorkout(context, doc),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$name selected (edit coming soon)")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "unique_${DateTime.now().millisecondsSinceEpoch}",
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, size: 32),
        onPressed: () {
          Navigator.pop(context);
          // Or push CreateWorkoutScreen directly
        },
      ),
    );
  }
}