// lib/features/trainer/presentation/my_programs_screen.dart
// 🔥 FIXED "No element" ERROR + BOTTOM SHEET PREVIEW
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'program_viewer_screen.dart';

class MyProgramsScreen extends StatelessWidget {
  const MyProgramsScreen({super.key});

  Future<void> _deleteProgram(BuildContext context, String programId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Program?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('trainers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('programs')
          .doc(programId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Program deleted"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 🔥 SAFE NAVIGATION - FIXES "No element" ERROR
  void _viewProgram(
      BuildContext context,
      String programId,
      Map<String, dynamic> data,
      dynamic weeksData,
      String name,
      int weeksCount) {
    List<dynamic> safeWeeks = [];
    if (weeksData is List && weeksData.isNotEmpty) {
      safeWeeks = List.from(weeksData);
    } else {
      safeWeeks = List.generate(weeksCount,
              (index) => {'week': index + 1, 'workouts': <Map<String, dynamic>>[]});
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgramViewerScreen(
          planMap: {
            "id": programId,
            "title": name,
            "duration": "$weeksCount weeks",
            "weeks": safeWeeks,
            ...Map<String, dynamic>.from(data),
          },
        ),
      ),
    );
  }

  void _showQuickPreview(BuildContext context, String programId,
      Map<String, dynamic> data, dynamic weeksData, String name, int weeksCount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        weeksCount.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      "$weeksCount week${weeksCount > 1 ? 's' : ''} program",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
              // Weeks list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: weeksData is List ? (weeksData as List).length : weeksCount,
                  itemBuilder: (context, weekIndex) {
                    final weekNum = weekIndex + 1;
                    int workoutCount = 0;

                    if (weeksData is List && weekIndex < weeksData.length) {
                      final week = weeksData[weekIndex];
                      if (week is Map? && week?['workouts'] is List?) {
                        final workouts = week?['workouts'] as List?;
                        if (workouts != null) {
                          workoutCount = workouts.length;
                        }
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            "W$weekNum",
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                        ),
                        title: Text(
                          "Week $weekNum",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text("$workoutCount workout${workoutCount != 1 ? 's' : ''}"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              // Buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Close"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _viewProgram(context, programId, data, weeksData, name, weeksCount);
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text("View Full Program"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Training Programs"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trainers')
            .doc(userId)
            .collection('programs')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading programs"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No programs yet",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Create one from Dashboard → Build Program"),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final programId = doc.id;

              final name = (data['name'] as String?)?.isNotEmpty == true
                  ? data['name']
                  : "Untitled Program";

              int weeksCount = 1;
              final weeksData = data['weeks'];
              if (weeksData is List && weeksData.isNotEmpty) {
                weeksCount = weeksData.length;
              } else if (weeksData is int && weeksData > 0) {
                weeksCount = weeksData;
              }

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(weeksCount.toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("$weeksCount week${weeksCount > 1 ? 's' : ''} • Tap to view"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProgram(context, programId),
                  ),
                  // ✅ CORRECT: Use children for buttons, NO onTap needed
                  childrenPadding: const EdgeInsets.only(left: 72, right: 16, top: 12, bottom: 16),
                  children: [
                    ListTile(
                      leading: Icon(Icons.preview, color: Colors.deepPurple[600]),
                      title: Text("Quick Preview", style: TextStyle(color: Colors.deepPurple[600])),
                      trailing: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: Colors.deepPurple.withOpacity(0.05),
                      onTap: () => _showQuickPreview(context, programId, data, weeksData, name, weeksCount),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _viewProgram(context, programId, data, weeksData, name, weeksCount),
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        label: const Text("View Full Program"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
