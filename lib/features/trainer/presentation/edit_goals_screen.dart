// lib/features/trainer/presentation/edit_goals_screen.dart

import 'package:flutter/material.dart';

class EditGoalsScreen extends StatefulWidget {
  final String clientName;
  const EditGoalsScreen({super.key, required this.clientName});

  @override
  State<EditGoalsScreen> createState() => _EditGoalsScreenState();
}

class _EditGoalsScreenState extends State<EditGoalsScreen> {
  final Map<String, TextEditingController> controllers = {
    "weight": TextEditingController(text: "75"),
    "bodyfat": TextEditingController(text: "18"),
    "muscle": TextEditingController(text: "42"),
    "weekly": TextEditingController(text: "4"),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Goals - ${widget.clientName}"), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _GoalCard(title: "Target Weight (kg)", controller: controllers["weight"]!, icon: Icons.monitor_weight),
            const SizedBox(height: 16),
            _GoalCard(title: "Target Body Fat (%)", controller: controllers["bodyfat"]!, icon: Icons.percent),
            const SizedBox(height: 16),
            _GoalCard(title: "Target Muscle Mass (kg)", controller: controllers["muscle"]!, icon: Icons.fitness_center),
            const SizedBox(height: 16),
            _GoalCard(title: "Workouts Per Week", controller: controllers["weekly"]!, icon: Icons.calendar_today),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Goals updated for ${widget.clientName}!"), backgroundColor: Colors.green[700]));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text("Save Goals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final IconData icon;
  const _GoalCard({required this.title, required this.controller, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 32),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), TextField(controller: controller, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), decoration: const InputDecoration(border: InputBorder.none))])),
        ],
      ),
    );
  }
}