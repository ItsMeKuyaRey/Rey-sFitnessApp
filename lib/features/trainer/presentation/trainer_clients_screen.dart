// lib/features/trainer/presentation/trainer_clients_screen.dart
// FINAL — WORKS ON FLUTTER 3.22+ (borderRadius fixed forever)

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fitnessapp/core/clients_database.dart';
import 'client_profile_screen.dart';

class TrainerClientsScreen extends StatefulWidget {
  const TrainerClientsScreen({super.key});

  @override
  State<TrainerClientsScreen> createState() => _TrainerClientsScreenState();
}

class _TrainerClientsScreenState extends State<TrainerClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  late List<Map<String, dynamic>> clients;

  @override
  void initState() {
    super.initState();
    clients = ClientsDatabase.instance.clients;
    ClientsDatabase.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    ClientsDatabase.instance.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => clients = ClientsDatabase.instance.clients);

  void _showAddClientDialog() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String avatarUrl =
        "https://i.pravatar.cc/150?u=${DateTime.now().millisecondsSinceEpoch}";

    final XFile? picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) avatarUrl = picked.path;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding:
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Drag handle
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Text("Add New Client",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CircleAvatar(
                radius: 50,
                backgroundImage: avatarUrl.startsWith("http")
                    ? NetworkImage(avatarUrl)
                    : FileImage(File(avatarUrl)) as ImageProvider),
            const SizedBox(height: 20),
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: "Full Name", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                    labelText: "Email", border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                    labelText: "Phone (+639...)", border: OutlineInputBorder()),
                keyboardType: TextInputType.phone),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty &&
                    phoneCtrl.text.trim().isNotEmpty) {
                  ClientsDatabase.instance.addClient(
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    avatarUrl: avatarUrl,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("${nameCtrl.text} added!"),
                      backgroundColor: Colors.green[700]));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              child: const Text("Add Client",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = clients
        .where((c) => c["name"]
        .toString()
        .toLowerCase()
        .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          title: const Text("My Clients",
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => searchQuery = v),
            decoration: const InputDecoration(
                hintText: "Search clients...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide.none)),
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${filtered.length} Clients",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                      "${filtered.where((c) => c["active"] == true).length} Active",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700])),
                ])),
        const SizedBox(height: 12),
        Expanded(
            child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) => _ClientCard(
                  client: filtered[i],
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ClientProfileScreen(
                              clientData: filtered[i]))),
                )))
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClientDialog,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text("Add Client", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// FINAL CLIENT CARD — borderRadius fixed inside BoxDecoration
class _ClientCard extends StatelessWidget {
  final Map<String, dynamic> client;
  final VoidCallback onTap;

  const _ClientCard({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String avatar = client["avatar"] ?? "https://i.pravatar.cc/150";
    final int progress = client["progress"] ?? 0;
    final bool active = client["active"] ?? true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          // ← THIS IS THE CORRECT WAY NOW
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(children: [
          Stack(children: [
            CircleAvatar(
                radius: 30,
                backgroundImage: avatar.startsWith("http")
                    ? NetworkImage(avatar)
                    : FileImage(File(avatar)) as ImageProvider),
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
                          border: Border.all(color: Colors.white, width: 3)))),
          ]),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client["name"],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(active ? "Active Member" : "Inactive",
                        style: TextStyle(
                            color: active ? Colors.green[700] : Colors.grey)),
                  ])),
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation(Colors.deepPurple)),
              Text("$progress%",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 10)),
            ]),
          ),
        ]),
      ),
    );
  }
}
