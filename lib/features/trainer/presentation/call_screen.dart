// lib/features/trainer/presentation/call_screen.dart
// FINAL FIXED — SHOWS THE EXACT SAME AVATAR + PHONE FROM DATABASE

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:fitnessapp/core/clients_database.dart';

class CallScreen extends StatelessWidget {
  final String clientName;
  const CallScreen({super.key, required this.clientName});

  // Get the REAL client data from database
  Map<String, dynamic> get _client {
    return ClientsDatabase.instance.clients.firstWhere(
          (c) => c["name"] == clientName,
      orElse: () => {"name": clientName, "avatar": "https://i.pravatar.cc/150", "phone": "Unknown"},
    );
  }

  String get _avatar => _client["avatar"] ?? "https://i.pravatar.cc/150";
  String get _phone => _client["phone"] ?? "";

  void _makeCall() async {
    if (_phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: _phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.call), onPressed: _makeCall)],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // EXACT SAME AVATAR AS PROFILE
            CircleAvatar(
              radius: 90,
              backgroundImage: _avatar.startsWith("http")
                  ? NetworkImage(_avatar)
                  : FileImage(File(_avatar)) as ImageProvider,
            ),
            const SizedBox(height: 30),
            Text(clientName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(_phone, style: TextStyle(fontSize: 20, color: Colors.green[700])),
            const SizedBox(height: 80),
            ElevatedButton.icon(
              onPressed: _makeCall,
              icon: const Icon(Icons.call, size: 32),
              label: const Text("Call Client Now", style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}