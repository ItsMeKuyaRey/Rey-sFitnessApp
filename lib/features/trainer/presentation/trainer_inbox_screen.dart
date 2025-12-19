// lib/features/trainer/presentation/trainer_inbox_screen.dart
// 🔥 NEW — SHOWS ALL CLIENT CHATS IN ONE PLACE

import 'package:flutter/material.dart';
import 'package:fitnessapp/core/clients_database.dart';
import 'trainer_messages_screen.dart';

class TrainerInboxScreen extends StatelessWidget {
  const TrainerInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clients = ClientsDatabase.instance.clients;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: clients.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text(
              "No clients yet",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Your client chats will appear here",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          final name = client["name"] as String;
          final avatar = client["avatar"] as String? ?? "https://i.pravatar.cc/150";
          final active = client["active"] as bool? ?? true;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(avatar),
                  ),
                  if (active)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                active ? "Active now" : "Offline",
                style: TextStyle(
                  color: active ? Colors.green[700] : Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrainerMessagesScreen(clientData: client),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}