import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(user["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user["avatar"]),
            ),
            const SizedBox(height: 20),
            Text(user["name"], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(user["email"], style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 30),
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.deepPurple),
                title: const Text("Member Since"),
                subtitle: Text(user["joined"]),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info, color: Colors.deepPurple),
                title: const Text("Status"),
                subtitle: Text(user["status"]),
                trailing: Icon(
                  user["isBanned"] ? Icons.block : Icons.check_circle,
                  color: user["isBanned"] ? Colors.red : Colors.green,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Editing ${user['name']}...")),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}