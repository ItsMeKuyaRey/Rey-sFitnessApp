// lib/core/clients_database.dart
// 🔥 UPDATED — Now includes Firebase-compatible clientId for chat system

import 'package:flutter/material.dart';

class ClientsDatabase extends ChangeNotifier {
  static final ClientsDatabase _instance = ClientsDatabase._internal();
  static ClientsDatabase get instance => _instance;
  ClientsDatabase._internal();

  // 🔥 EACH CLIENT NOW HAS A UNIQUE clientId (acts like Firebase UID)
  final List<Map<String, dynamic>> _clients = [
    {
      "id": "client_001", // 🔥 NEW: Unique ID for chat system
      "name": "Sarah Johnson",
      "email": "sarah.johnson@email.com",
      "phone": "+639171234567",
      "avatar": "https://i.pravatar.cc/150?img=5",
      "streak": 21,
      "workoutsCompleted": 48,
      "joinDate": DateTime(2024, 6, 15),
      "lastActive": DateTime.now(),
      "progress": 78,
      "active": true,
    },
    {
      "id": "client_002",
      "name": "Mike Chen",
      "email": "mike.chen@email.com",
      "phone": "+639181234567",
      "avatar": "https://i.pravatar.cc/150?img=12",
      "streak": 15,
      "workoutsCompleted": 36,
      "joinDate": DateTime(2024, 7, 20),
      "lastActive": DateTime.now().subtract(const Duration(days: 1)),
      "progress": 65,
      "active": true,
    },
    {
      "id": "client_003",
      "name": "Emma Davis",
      "email": "emma.davis@email.com",
      "phone": "+639191234567",
      "avatar": "https://i.pravatar.cc/150?img=9",
      "streak": 10,
      "workoutsCompleted": 25,
      "joinDate": DateTime(2024, 8, 5),
      "lastActive": DateTime.now(),
      "progress": 52,
      "active": true,
    },
    {
      "id": "client_004",
      "name": "Carlos Rodriguez",
      "email": "carlos.rodriguez@email.com",
      "phone": "+639201234567",
      "avatar": "https://i.pravatar.cc/150?img=33",
      "streak": 8,
      "workoutsCompleted": 18,
      "joinDate": DateTime(2024, 9, 1),
      "lastActive": DateTime.now().subtract(const Duration(days: 3)),
      "progress": 45,
      "active": true,
    },
    {
      "id": "client_005",
      "name": "Lisa Park",
      "email": "lisa.park@email.com",
      "phone": "+639211234567",
      "avatar": "https://i.pravatar.cc/150?img=47",
      "streak": 5,
      "workoutsCompleted": 12,
      "joinDate": DateTime(2024, 9, 15),
      "lastActive": DateTime.now().subtract(const Duration(days: 5)),
      "progress": 30,
      "active": false,
    },
    {
      "id": "client_006",
      "name": "Alex Turner",
      "email": "alex.turner@email.com",
      "phone": "+639221234567",
      "avatar": "https://i.pravatar.cc/150?img=68",
      "streak": 3,
      "workoutsCompleted": 8,
      "joinDate": DateTime(2024, 10, 1),
      "lastActive": DateTime.now().subtract(const Duration(days: 2)),
      "progress": 25,
      "active": true,
    },
  ];

  List<Map<String, dynamic>> get clients => List.unmodifiable(_clients);

  void addClient({
    required String name,
    required String email,
    required String phone,
    required String avatarUrl,
  }) {
    // Generate unique ID for new clients
    final newId = "client_${DateTime.now().millisecondsSinceEpoch}";

    _clients.add({
      "id": newId, // 🔥 NEW
      "name": name,
      "email": email,
      "phone": phone,
      "avatar": avatarUrl,
      "streak": 0,
      "workoutsCompleted": 0,
      "joinDate": DateTime.now(),
      "lastActive": DateTime.now(),
      "progress": 0,
      "active": true,
    });
    notifyListeners();
  }

  // 🔥 NEW: Get client by ID (useful for chat system)
  Map<String, dynamic>? getClientById(String clientId) {
    try {
      return _clients.firstWhere((c) => c["id"] == clientId);
    } catch (e) {
      return null;
    }
  }

  // 🔥 NEW: Get client by name (for backward compatibility)
  Map<String, dynamic>? getClientByName(String name) {
    try {
      return _clients.firstWhere((c) => c["name"] == name);
    } catch (e) {
      return null;
    }
  }
}