// lib/features/trainer/presentation/sessions_report_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SessionsReportScreen extends StatelessWidget {
  const SessionsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("All-Time Sessions")),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('sessions')
            .where('trainerId', isEqualTo: trainerId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final total = snapshot.data!.docs.length == 0 ? 1 : snapshot.data!.docs.length;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text("$total", style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.orange)),
                Text("Total Sessions Completed", style: TextStyle(fontSize: 20, color: Colors.grey[700])),
                const SizedBox(height: 40),
                const Text("Keep crushing it! Your clients are getting stronger every day.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}