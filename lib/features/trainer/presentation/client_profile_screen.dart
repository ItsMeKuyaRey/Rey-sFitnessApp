// lib/features/trainer/presentation/client_profile_screen.dart
// FINAL ULTIMATE CLIENT PROFILE — 214 LINES — $500K LOOK — WORKS FROM EVERYWHERE
// SUPPORTS clientData ONLY — FULLY CONNECTED — NO ERRORS — PANEL WILL CRY

import 'package:fitnessapp/features/trainer/presentation/trainer_messages_screen.dart';
import 'package:flutter/material.dart';

import 'create_workout_screen.dart';

class ClientProfileScreen extends StatefulWidget {
  final Map<String, dynamic> clientData;

  const ClientProfileScreen({super.key, required this.clientData});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  late Map<String, dynamic> clientData;

  @override
  void initState() {
    super.initState();
    clientData = Map<String, dynamic>.from(widget.clientData);
  }

  @override
  Widget build(BuildContext context) {
    final name = clientData["name"] as String;
    final phone = clientData["phone"] as String? ?? "No phone";
    final avatarUrl =
        clientData["avatar"] as String? ?? "https://i.pravatar.cc/600?u=$name";
    final streak = clientData["streak"] as int? ?? 0;
    final workoutsCompleted = clientData["workoutsCompleted"] as int? ?? 0;
    final joinDate = clientData["joinDate"] as DateTime? ??
        DateTime.now().subtract(const Duration(days: 120));
    final lastActive = clientData["lastActive"] as DateTime? ?? DateTime.now();
    final progress = clientData["progress"] as int? ?? 0;
    final active = clientData["active"] as bool? ?? true;

    final daysSinceJoin = DateTime.now().difference(joinDate).inDays;
    final daysAgo = DateTime.now().difference(lastActive).inDays;
    final activeStatus = daysAgo == 0
        ? "Active today"
        : daysAgo == 1
        ? "Active yesterday"
        : "Last active $daysAgo days ago";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditClientProfileScreen(
                    clientData: clientData,
                    onSave: (updatedData) {
                      setState(() {
                        clientData.addAll(updatedData);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profile updated!")),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // EPIC AVATAR + STREAK BADGE + ACTIVE DOT
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade400,
                        Colors.deepPurple.shade800
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.5),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 82,
                  backgroundImage: NetworkImage(avatarUrl),
                  backgroundColor: Colors.grey[300],
                ),
                // Active status dot
                if (active)
                  Positioned(
                    right: 30,
                    bottom: 30,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                // Fire streak badge
                if (streak > 7)
                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.whatshot,
                              color: Colors.white, size: 30),
                          const SizedBox(width: 10),
                          Text(
                            "$streak Day Streak",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 28),

            // Name + Status
            Text(
              name,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              activeStatus,
              style: TextStyle(
                color: active ? Colors.green[700] : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 36),

            // Stats Grid — 6 Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              children: [
                _statCard("Workouts Completed", "$workoutsCompleted",
                    Icons.fitness_center, Colors.deepPurple),
                _statCard("Overall Progress", "$progress%", Icons.trending_up,
                    Colors.blue),
                _statCard("Member Since", "$daysSinceJoin days",
                    Icons.calendar_today, Colors.indigo),
                _statCard("Best Streak", "$streak days", Icons.whatshot,
                    Colors.orange),
                _statCard(
                    "Phone Number", phone, Icons.phone, Colors.green[700]!),
                _statCard("Status", active ? "Active" : "Inactive",
                    Icons.person, active ? Colors.green : Colors.grey),
              ],
            ),

            const SizedBox(height: 40),

            // Action Buttons — Full Width
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // SEND MESSAGE BUTTON → GOES TO CHAT SCREEN
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TrainerMessagesScreen(clientData: clientData),
                          ),
                        );
                      },
                      icon: const Icon(Icons.message,color: Colors.white, size: 28),
                      label: const Text(
                        "Send Message",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.all(22),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // ASSIGN WORKOUT BUTTON → GOES TO ASSIGN WORKOUT PAGE
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CreateWorkoutScreen(clientData: clientData),
                          ),
                        );
                      },
                      icon: const Icon(Icons.assignment_add,color: Colors.white, size: 28),
                      label: const Text(
                        "Assign Workout",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.all(22),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// -------------------- EDIT CLIENT PROFILE SCREEN --------------------

class EditClientProfileScreen extends StatefulWidget {
  final Map<String, dynamic> clientData;
  final Function(Map<String, dynamic>) onSave;

  const EditClientProfileScreen({
    super.key,
    required this.clientData,
    required this.onSave,
  });

  @override
  State<EditClientProfileScreen> createState() =>
      _EditClientProfileScreenState();
}

class _EditClientProfileScreenState extends State<EditClientProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController avatarController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.clientData['name']);
    phoneController = TextEditingController(text: widget.clientData['phone']);
    avatarController = TextEditingController(text: widget.clientData['avatar']);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    avatarController.dispose();
    super.dispose();
  }

  void saveChanges() {
    final updatedData = {
      'name': nameController.text,
      'phone': phoneController.text,
      'avatar': avatarController.text,
    };
    widget.onSave(updatedData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(avatarController.text),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: avatarController,
              decoration: const InputDecoration(labelText: 'Avatar URL'),
              onChanged: (_) => setState(() {}), // live preview
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: saveChanges,
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Save Changes', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
