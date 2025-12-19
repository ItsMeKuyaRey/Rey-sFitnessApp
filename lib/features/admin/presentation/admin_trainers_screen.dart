// lib/features/admin/presentation/admin_trainers_screen.dart
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';


class AdminTrainersScreen extends StatefulWidget {
  const AdminTrainersScreen({super.key});

  @override
  State<AdminTrainersScreen> createState() => _AdminTrainersScreenState();
}

class _AdminTrainersScreenState extends State<AdminTrainersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _filterStatus = "All";

  final List<Map<String, dynamic>> _trainers = [
    {
      "name": "Sarah Johnson",
      "specialty": "HIIT & Strength",
      "status": "Approved",
      "clients": 24,
      "avatar": "S"
    },
    {
      "name": "Mike Chen",
      "specialty": "Yoga & Mobility",
      "status": "Pending",
      "clients": 8,
      "avatar": "M"
    },
    {
      "name": "Emma Davis",
      "specialty": "Weight Loss",
      "status": "Pending",
      "clients": 12,
      "avatar": "E"
    },
    {
      "name": "Alex Rivera",
      "specialty": "Powerlifting",
      "status": "Approved",
      "clients": 18,
      "avatar": "A"
    },
    {
      "name": "Lisa Wong",
      "specialty": "Pilates & Core",
      "status": "Approved",
      "clients": 32,
      "avatar": "L"
    },
    {
      "name": "David Kim",
      "specialty": "Cardio Specialist",
      "status": "Rejected",
      "clients": 0,
      "avatar": "D"
    },
  ];

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  Color get _backgroundColor =>
      _isDarkMode ? const Color(0xFF121212) : Colors.grey[100]!;

  Color get _cardColor => _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

  Color get _textColor => _isDarkMode ? Colors.white : Colors.black87;

  Color get _secondaryTextColor =>
      _isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey[600]!;

  List<Map<String, dynamic>> get _filteredTrainers {
    return _trainers.where((trainer) {
      final matchesSearch = trainer["name"]
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          trainer["specialty"]
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _filterStatus == "All" || trainer["status"] == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _approveTrainer(int index) {
    setState(() => _trainers[index]["status"] = "Approved");
    _showSnackBar("${_trainers[index]['name']} approved!", Colors.green);
  }

  void _rejectTrainer(int index) {
    setState(() => _trainers[index]["status"] = "Rejected");
    _showSnackBar("${_trainers[index]['name']} rejected!", Colors.red);
  }

  void _deleteTrainer(int index) {
    final name = _trainers[index]["name"];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete Trainer", style: TextStyle(color: _textColor)),
        content: Text("Delete $name permanently?",
            style: TextStyle(color: _secondaryTextColor)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _trainers.removeAt(index));
              Navigator.pop(ctx);
              _showSnackBar("Trainer deleted", Colors.red);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _viewTrainerProfile(int index) {
    final trainer = _trainers[index];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(trainer["name"],
            style: TextStyle(fontWeight: FontWeight.bold, color: _textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("Specialty", trainer["specialty"]),
            _infoRow("Clients", trainer["clients"].toString()),
            _infoRow("Status", trainer["status"],
                color: trainer["status"] == "Approved"
                    ? Colors.green
                    : trainer["status"] == "Pending"
                        ? Colors.orange
                        : Colors.red),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () =>
                _showSnackBar("Analytics coming soon...", Colors.deepPurple),
            child: const Text("View Analytics"),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: _textColor),
          children: [
            TextSpan(
                text: "$label: ",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text: value,
                style: TextStyle(color: color ?? _secondaryTextColor)),
          ],
        ),
      ),
    );
  }

  void _inviteTrainerByEmail() {
    final emailController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Invite Trainer",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: "Trainer Name", hintText: "John Doe")),
            const SizedBox(height: 12),
            TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: "Email", hintText: "trainer@example.com")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              final name = nameController.text.trim();
              final email = emailController.text.trim();

              if (name.isNotEmpty && email.isNotEmpty) {
                Navigator.pop(ctx);
                _sendManualEmail(name, email);
                _showSnackBar("Email ready to send to $email", Colors.green);
              } else {
                _showSnackBar("Please enter both name and email", Colors.red);
              }
            },
            child: const Text("Send Invite"),
          ),
        ],
      ),
    );
  }


  void _addTrainerManually() {
    final nameController = TextEditingController();
    final specialtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add New Trainer",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name")),
            const SizedBox(height: 8),
            TextField(
                controller: specialtyController,
                decoration:
                    const InputDecoration(labelText: "Specialty (optional)")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _trainers.add({
                    "name": nameController.text.trim(),
                    "specialty": specialtyController.text.isEmpty
                        ? "General Fitness"
                        : specialtyController.text.trim(),
                    "status": "Approved",
                    "clients": 0,
                    "avatar": nameController.text.trim().isEmpty
                        ? "T"
                        : nameController.text.trim()[0].toUpperCase(),
                  });
                });
                Navigator.pop(ctx);
                _showSnackBar("${nameController.text} added!", Colors.green);
              }
            },
            child: const Text("Add Trainer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sendManualEmail(String name, String email) async {
    final Uri mailto = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Trainer Invitation',
        'body':
        'Hello $name,\n\nYou have been invited to join as a trainer on our fitness app.\n\nPlease register using this link: [Insert Registration Link Here]\n\nThanks!',
      },
    );

    if (!await launchUrl(mailto, mode: LaunchMode.externalApplication)) {
      _showSnackBar('Could not open email app', Colors.red);
    }
  }


  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final pendingCount =
        _trainers.where((t) => t["status"] == "Pending").length;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(tr.translate("Manage Trainers"),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: TextStyle(color: _textColor),
                  decoration: InputDecoration(
                    hintText: tr.translate("Search trainers..."),
                    hintStyle: TextStyle(color: _secondaryTextColor),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.deepPurple),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: _cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        decoration: InputDecoration(
                          labelText: tr.translate("Status"),
                          filled: true,
                          fillColor: _cardColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none),
                        ),
                        items: ["All", "Pending", "Approved", "Rejected"]
                            .map((s) => DropdownMenuItem(
                                value: s, child: Text(tr.translate(s))))
                            .toList(),
                        onChanged: (v) => setState(() => _filterStatus = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _inviteTrainerByEmail,
                      icon: const Icon(Icons.email_outlined),
                      label: Text(tr.translate("Invite")),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatCard(
                    "Total", _trainers.length.toString(), Colors.deepPurple),
                const SizedBox(width: 12),
                _buildStatCard(
                    "Pending", pendingCount.toString(), Colors.orange),
                const SizedBox(width: 12),
                _buildStatCard("Clients", "124", Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredTrainers.isEmpty
                ? Center(
                    child: Text(tr.translate("No trainers found"),
                        style: TextStyle(
                            color: _secondaryTextColor, fontSize: 18)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredTrainers.length,
                    itemBuilder: (context, i) {
                      final trainer = _filteredTrainers[i];
                      final originalIndex = _trainers.indexOf(trainer);
                      final isPending = trainer["status"] == "Pending";

                      return Card(
                        color: _cardColor,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.deepPurple.withAlpha(50),
                            child: Text(trainer["avatar"],
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple)),
                          ),
                          title: Text(trainer["name"],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _textColor)),
                          subtitle: Text(trainer["specialty"],
                              style: TextStyle(color: _secondaryTextColor)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isPending
                                      ? Colors.orange.withAlpha(40)
                                      : trainer["status"] == "Approved"
                                          ? Colors.green.withAlpha(40)
                                          : Colors.red.withAlpha(40),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  trainer["status"],
                                  style: TextStyle(
                                    color: isPending
                                        ? Colors.orange[700]!
                                        : trainer["status"] == "Approved"
                                            ? Colors.green[700]!
                                            : Colors.red[700]!,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              IconButton(
                                  icon: const Icon(Icons.visibility,
                                      color: Colors.deepPurple),
                                  onPressed: () =>
                                      _viewTrainerProfile(originalIndex)),
                              if (isPending) ...[
                                IconButton(
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    onPressed: () =>
                                        _approveTrainer(originalIndex)),
                                IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _rejectTrainer(originalIndex)),
                              ] else
                                PopupMenuButton(
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      onTap: () =>
                                          _deleteTrainer(originalIndex),
                                      child: const Row(children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text("Delete",
                                            style: TextStyle(color: Colors.red))
                                      ]),
                                    ),
                                  ],
                                  icon: const Icon(Icons.more_vert),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "trainers_screen_fab",
        backgroundColor: Colors.deepPurple,
        onPressed: _addTrainerManually,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text("Add Trainer", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(color: _secondaryTextColor, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
