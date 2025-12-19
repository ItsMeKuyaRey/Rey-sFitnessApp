// lib/features/trainer/presentation/client_reports_screen.dart
// FINAL — NO OVERFLOW — PERFECT LAYOUT — PREMIUM AS FUCK

import 'package:flutter/material.dart';
import 'package:fitnessapp/core/clients_database.dart';

import 'client_profile_screen.dart';

class ClientReportsScreen extends StatelessWidget {
  const ClientReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clients = ClientsDatabase.instance.clients;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Client Reports",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: clients.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_alt_outlined,
                size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text("No clients assigned",
                style:
                TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Your clients will appear here",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          final name = client["name"] as String;
          final phone = client["phone"] as String? ?? "No phone";
          final avatarUrl = client["avatar"] as String? ??
              "https://i.pravatar.cc/400?u=$name";
          final streak = client["streak"] as int? ?? 0;
          final workoutsCompleted =
              client["workoutsCompleted"] as int? ?? 0;
          final lastActive = client["lastActive"] as DateTime? ??
              DateTime.now().subtract(Duration(days: index + 1));

          final daysAgo = DateTime.now().difference(lastActive).inDays;
          final activeText = daysAgo == 0
              ? "Today"
              : daysAgo == 1
              ? "Yesterday"
              : "$daysAgo days ago";

          return AnimatedContainer(
            duration: Duration(milliseconds: 600 + index * 80),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 18),
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientProfileScreen(clientData: client),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 22),
                  child: Row(
                    children: [
                      // Avatar + Streak
                      Stack(
                        children: [
                          CircleAvatar(
                              radius: 38,
                              backgroundImage: NetworkImage(avatarUrl)),
                          if (streak > 7)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6)
                                  ],
                                ),
                                child: Text("$streak",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Name + Phone + Stats (THIS WAS CAUSING OVERFLOW)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(phone,
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14)),
                            const SizedBox(height: 12),
                            // FIXED: Wrapped in FittedBox to prevent overflow
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.fitness_center,
                                      color: Colors.deepPurple, size: 20),
                                  const SizedBox(width: 6),
                                  Text("$workoutsCompleted workouts",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 16),
                                  Icon(Icons.access_time,
                                      color: Colors.green[700], size: 18),
                                  const SizedBox(width: 6),
                                  Text(activeText,
                                      style: TextStyle(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.chevron_right,
                          size: 34, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
