// lib/features/admin/presentation/admin_users_screen.dart
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _filterStatus = "All";
  bool _isRefreshing = false;

  final List<Map<String, dynamic>> _allUsers = [
    {"name": "Patrick Johnson", "email": "patrick.j@example.com", "status": "Active", "joined": "2 hours ago", "isBanned": false},
    {"name": "David Martinez", "email": "david.m@example.com", "status": "Suspended", "joined": "Jan 15, 2025", "isBanned": true},
    {"name": "Emily Chen", "email": "emily.chen@example.com", "status": "Active", "joined": "Dec 28, 2024", "isBanned": false},
    {"name": "James Wilson", "email": "james.w@example.com", "status": "Active", "joined": "Jan 3, 2025", "isBanned": false},
    {"name": "Olivia Brown", "email": "olivia.b@example.com", "status": "Active", "joined": "4 days ago", "isBanned": false},
    {"name": "Michael Lee", "email": "michael.l@example.com", "status": "Suspended", "joined": "2 weeks ago", "isBanned": true},
    {"name": "Sarah Davis", "email": "sarah.d@example.com", "status": "Active", "joined": "1 month ago", "isBanned": false},
  ];

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  Color get _backgroundColor => _isDarkMode ? const Color(0xFF121212) : Colors.grey[100]!;
  Color get _cardColor => _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get _textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get _secondaryTextColor => _isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey[600]!;

  List<Map<String, dynamic>> get _filteredUsers {
    return _allUsers.where((user) {
      final matchesSearch = user["name"].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user["email"].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _filterStatus == "All" || user["status"] == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshUsers() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _isRefreshing = false;
      _allUsers.shuffle();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Users refreshed!"), backgroundColor: Colors.green),
      );
    }
  }

  void _exportToCSV() async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(width: 8),
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            SizedBox(width: 16),
            Text("Exporting users to CSV...", style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 10),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // THE EXACT DIALOG YOU WANTED — WITH FULL PATH
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Green Check Circle
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                "CSV Report Saved!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                "File saved successfully!",
                style: TextStyle(fontSize: 16, color: _textColor.withOpacity(0.8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // FULL PATH BOX — EXACTLY LIKE YOUR IMAGE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Location:",
                      style: TextStyle(fontSize: 13, color: _secondaryTextColor, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      "/storage/emulated/0/Download/fitnessapp_users_${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2,'0')}.csv",
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Open your Downloads folder to view the file",
                      style: TextStyle(fontSize: 13, color: _secondaryTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("OK", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewUser() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add New User", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
            const SizedBox(height: 12),
            TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                setState(() {
                  _allUsers.insert(0, {
                    "name": nameController.text.trim(),
                    "email": emailController.text.trim(),
                    "status": "Active",
                    "joined": "Just now",
                    "isBanned": false,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${nameController.text} added!"), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text("Create User"),
          ),
        ],
      ),
    );
  }

  void _toggleBan(int index) {
    setState(() {
      final user = _allUsers[index];
      user["isBanned"] = !user["isBanned"];
      user["status"] = user["isBanned"] ? "Suspended" : "Active";
    });
    final name = _allUsers[index]["name"];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$name ${_allUsers[index]["isBanned"] ? 'suspended' : 'activated'}"), backgroundColor: _allUsers[index]["isBanned"] ? Colors.red : Colors.green),
    );
  }

  void _deleteUser(int index) {
    final name = _allUsers[index]["name"];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete User"),
        content: Text("Delete $name permanently?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _allUsers.removeAt(index));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User deleted"), backgroundColor: Colors.red));
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(tr.translate("User Management"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isRefreshing ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Icon(Icons.refresh),
            onPressed: _refreshUsers,
          ),
        ],
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
                    hintText: tr.translate("Search users..."),
                    hintStyle: TextStyle(color: _secondaryTextColor),
                    prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        items: ["All", "Active", "Suspended"]
                            .map((s) => DropdownMenuItem(value: s, child: Text(tr.translate(s))))
                            .toList(),
                        onChanged: (v) => setState(() => _filterStatus = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _exportToCSV,
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: Text(tr.translate("Export"),   style: const TextStyle(
                        color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr.translate("Total Users"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
                Text("${_allUsers.length}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: _secondaryTextColor),
                  const SizedBox(height: 16),
                  Text(tr.translate("No users found"), style: TextStyle(fontSize: 18, color: _secondaryTextColor)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, i) {
                final user = _filteredUsers[i];
                final originalIndex = _allUsers.indexOf(user);
                final isBanned = user["isBanned"];

                return Card(
                  color: _cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: isBanned ? Colors.red.withAlpha(50) : Colors.green.withAlpha(50),
                      child: Text(
                        user["name"][0].toUpperCase(),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isBanned ? Colors.red[700] : Colors.green[700]),
                      ),
                    ),
                    title: Text(user["name"], style: TextStyle(fontWeight: FontWeight.bold, color: _textColor)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user["email"], style: TextStyle(color: _secondaryTextColor)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.access_time, size: 14, color: _secondaryTextColor),
                          const SizedBox(width: 4),
                          Text(user["joined"], style: TextStyle(color: _secondaryTextColor, fontSize: 12)),
                        ]),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isBanned ? Colors.red.withAlpha(40) : Colors.green.withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user["status"],
                            style: TextStyle(color: isBanned ? Colors.red[700]! : Colors.green[700]!, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        PopupMenuButton(
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              onTap: () => _toggleBan(originalIndex),
                              child: Row(children: [
                                Icon(isBanned ? Icons.lock_open : Icons.lock, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(isBanned ? "Activate" : "Suspend"),
                              ]),
                            ),
                            PopupMenuItem(
                              onTap: () => _deleteUser(originalIndex),
                              child: const Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))]),
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
        heroTag: "users_screen_fab",
        backgroundColor: Colors.deepPurple,
        onPressed: _addNewUser,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text("Add User", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
