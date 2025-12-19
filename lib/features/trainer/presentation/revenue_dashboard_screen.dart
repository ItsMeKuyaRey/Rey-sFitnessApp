// lib/features/trainer/presentation/revenue_dashboard_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RevenueDashboardScreen extends StatelessWidget {
  const RevenueDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Revenue Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .where('trainerId', isEqualTo: trainerId)
            .where('isPaid', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final paidSessions = snapshot.data!.docs;
          final revenue = paidSessions.length * 80; // $80 per session

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text("\$$revenue",
                    style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple)),
                const Text("Earned This Month", style: TextStyle(fontSize: 22)),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),
                Text("${paidSessions.length} Paid Sessions",
                    style: const TextStyle(fontSize: 18)),
                Text("Rate: \$80/session",
                    style: TextStyle(color: Colors.grey[600])),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16)),
                  child: const Text(
                    "Withdraw Earnings",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
