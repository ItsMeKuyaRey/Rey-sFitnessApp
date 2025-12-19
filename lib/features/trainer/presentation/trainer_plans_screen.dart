// lib/features/trainer/presentation/trainer_plans_screen.dart
// FINAL — NO DUPLICATES — TEXT NOW WHITE & READABLE ON COVER IMAGES

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fitnessapp/features/trainer/presentation/program_library_screen.dart';
import 'package:fitnessapp/features/trainer/presentation/program_viewer_screen.dart';
import 'package:fitnessapp/features/trainer/presentation/workout_plans_database.dart';

class TrainerPlansScreen extends StatefulWidget {
  const TrainerPlansScreen({super.key});

  @override
  State<TrainerPlansScreen> createState() => _TrainerPlansScreenState();
}

class _TrainerPlansScreenState extends State<TrainerPlansScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    WorkoutPlansDatabase.instance.addListener(_refresh);
    _searchController.addListener(
          () => setState(() => searchQuery = _searchController.text),
    );
  }

  @override
  void dispose() {
    WorkoutPlansDatabase.instance.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  List<WorkoutPlan> get filteredPlans {
    final all = WorkoutPlansDatabase.instance.plans;
    if (searchQuery.isEmpty) return all;
    return all
        .where((p) => p.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void _deletePlan(String id, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete \"$title\"?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              WorkoutPlansDatabase.instance.deletePlan(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$title deleted"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Workout Plans",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search plans...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => searchQuery = "");
                  },
                )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: filteredPlans.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined,
                size: 80, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              "No plans yet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap + to create your first program",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,  // ← Pure white for high contrast
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredPlans.length,
        itemBuilder: (context, index) {
          final plan = filteredPlans[index];
          final colors = [
            Colors.deepPurple,
            Colors.redAccent,
            Colors.teal,
            Colors.orange,
            Colors.blue,
            Colors.pink
          ];
          final color = colors[index % colors.length];

          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                // COVER IMAGE + USERS COUNT + TITLE/DURATION OVERLAY
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _showAssignedClients(context, plan),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        child: plan.imagePath.startsWith('http')
                            ? Image.network(
                          plan.imagePath,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Image.file(
                          File(plan.imagePath),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Dark gradient overlay for text readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 120,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black87,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Users count badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${plan.usersCount} users",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    // Title + Duration (now white, on dark gradient)
                    Positioned(
                      bottom: 16,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.title,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "Duration: ${plan.duration}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Buttons section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // EDIT PLAN
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProgramLibraryScreen(
                                isEdit: true,
                                planToEdit: plan,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Edit Plan",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // VIEW PLAN
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProgramViewerScreen(
                                planMap: plan.toDisplayMap(color),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text("View"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: color,
                          side: BorderSide(color: color, width: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // SEND + DELETE
                      Row(
                        children: [
                          FloatingActionButton.small(
                            heroTag: "send_$index",
                            backgroundColor: color,
                            onPressed: () =>
                                _showClientPicker(context, plan),
                            child: const Icon(Icons.send,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton.small(
                            heroTag: "delete_$index",
                            backgroundColor: Colors.redAccent,
                            onPressed: () =>
                                _deletePlan(plan.id, plan.title),
                            child: const Icon(Icons.delete_forever,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Create New Plan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProgramLibraryScreen(isEdit: false),
            ),
          );
        },
      ),
    );
  }

  // _showAssignedClients and _showClientPicker remain unchanged (same as previous version)
  void _showAssignedClients(BuildContext context, WorkoutPlan plan) {
    if (plan.assignedTo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No clients assigned yet")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${plan.title} — Assigned To",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            ...plan.assignedTo.map(
                  (name) => ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                  NetworkImage("https://i.pravatar.cc/150?u=$name"),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showClientPicker(BuildContext context, WorkoutPlan plan) {
    final clients = [
      "Rey",
      "Emma Wilson",
      "James Carter",
      "Sophia Martinez",
      "Liam Brown",
      "Olivia Davis",
      "Noah Kim",
      "Ava Brown"
    ];
    final color = [
      Colors.deepPurple,
      Colors.redAccent,
      Colors.teal,
      Colors.orange,
      Colors.blue,
      Colors.pink
    ][plan.id.hashCode.abs() % 6];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                "Assign '${plan.title}'",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  hintText: "Search clients...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: clients.length,
                  itemBuilder: (_, i) {
                    final name = clients[i];
                    final isAssigned = plan.assignedTo.contains(name);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?img=${i + 1}",
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: isAssigned
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          final updated = WorkoutPlan(
                            id: plan.id,
                            title: plan.title,
                            duration: plan.duration,
                            usersCount: plan.usersCount + 1,
                            assignedTo: [...plan.assignedTo, name],
                            imagePath: plan.imagePath,
                            weeks: plan.weeks,
                          );
                          WorkoutPlansDatabase.instance
                              .updatePlan(plan.id, updated);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Assigned to $name!"),
                              backgroundColor: Colors.green[700],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Assign",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}