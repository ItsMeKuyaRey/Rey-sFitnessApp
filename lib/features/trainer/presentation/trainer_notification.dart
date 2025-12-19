// lib/features/trainer/presentation/trainer_notification.dart
// FINAL — ONLY BOTTOM "Alerts" ICON SHOWS BADGE (NO TOP BELL)

import 'package:flutter/material.dart';

class TrainerNotificationsScreen extends StatefulWidget {
  final VoidCallback? onNotificationsRead;
  const TrainerNotificationsScreen({super.key, this.onNotificationsRead});

  @override
  State<TrainerNotificationsScreen> createState() => _TrainerNotificationsScreenState();
}

class _TrainerNotificationsScreenState extends State<TrainerNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // FIXED: No more setState() during build → no red screen!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onNotificationsRead?.call();
    });
  }

  List<Map<String, dynamic>> notifications = [
    {
      "id": "1",
      "type": "system",
      "title": "System Update Available",
      "subtitle": "New features and performance improvements are ready",
      "time": "2m ago",
      "icon": Icons.update,
      "color": Colors.blue,
      "read": false,
    },
    {
      "id": "2",
      "type": "client",
      "title": "Plan Completed!",
      "subtitle": "Sarah Anderson just completed 'Weight Loss Pro'",
      "clientName": "Sarah Anderson",
      "planTitle": "Weight Loss Pro",
      "time": "15m ago",
      "icon": Icons.check_circle,
      "color": Colors.green,
      "read": false,
    },
    {
      "id": "3",
      "type": "message",
      "title": "New Message",
      "subtitle": "Mike Davis sent you a message about diet plan",
      "clientName": "Mike Davis",
      "time": "1h ago",
      "icon": Icons.message,
      "color": Colors.orange,
      "read": true,
    },
    {
      "id": "4",
      "type": "payment",
      "title": "Payment Issue",
      "subtitle": "Payment failed for premium subscription",
      "clientName": "Alex Turner",
      "time": "3h ago",
      "icon": Icons.payment,
      "color": Colors.red,
      "read": true,
    },
    {
      "id": "5",
      "type": "achievement",
      "title": "Client Achievement",
      "subtitle": "David Kim just hit a 30-day workout streak!",
      "clientName": "David Kim",
      "streak": 30,
      "time": "1d ago",
      "icon": Icons.emoji_events,
      "color": Colors.purple,
      "read": true,
    },
  ];

  String filter = "user";
  String searchQuery = "";

  int get unreadCount => notifications.where((n) => !n["read"]).length;

  List<Map<String, dynamic>> get filteredNotifications {
    return notifications.where((n) {
      final matchesFilter = filter == "system"
          ? (n["type"] == "system" || n["type"] == "payment")
          : (n["type"] == "client" || n["type"] == "message" || n["type"] == "achievement");
      final matchesSearch = searchQuery.isEmpty ||
          n["title"].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          n["subtitle"].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _markAllRead() {
    setState(() {
      notifications = notifications.map((n) => {...n, "read": true}).toList();
    });
    // Badge disappears instantly when user taps "Mark All as Read"
    widget.onNotificationsRead?.call();
  }

  void _markAsRead(String id) {
    setState(() {
      final idx = notifications.indexWhere((e) => e["id"] == id);
      if (idx != -1) notifications[idx]["read"] = true;
    });
  }

  void _handleTap(Map<String, dynamic> n) {
    _markAsRead(n["id"]);
    switch (n["type"]) {
      case "client":
        Navigator.push(context, MaterialPageRoute(builder: (_) => ClientProgressScreen(clientName: n["clientName"])));
        break;
      case "message":
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(clientName: n["clientName"])));
        break;

      case "system":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemUpdateScreen()));
        break;
      case "payment":
        Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentIssueScreen(clientName: n["clientName"] ?? "Client")));
        break;
      case "achievement":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClientProgressScreen(clientName: n["clientName"] ?? "Client"),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update notes opening...")));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // TABS
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                _tab("System Alerts", "system"),
                _tab("User Updates", "user"),
              ],
            ),
          ),

          // SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search notifications...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.tune),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),

          // MARK ALL READ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: unreadCount > 0 ? _markAllRead : null,
                child: Text(
                  "Mark All as Read",
                  style: TextStyle(color: unreadCount > 0 ? Colors.deepPurple : Colors.grey),
                ),
              ),
            ),
          ),

          // LIST
          Expanded(
            child: filteredNotifications.isEmpty
                ? const Center(child: Text("No notifications", style: TextStyle(fontSize: 18, color: Colors.grey)))
                : ListView.builder(
              itemCount: filteredNotifications.length,
              itemBuilder: (context, i) {
                final n = filteredNotifications[i];
                return Dismissible(
                  key: Key(n["id"]),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ),
                  onDismissed: (_) => setState(() => notifications.remove(n)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: n["color"].withOpacity(0.2),
                      child: Icon(n["icon"], color: n["color"]),
                    ),
                    title: Text(n["title"], style: TextStyle(fontWeight: n["read"] ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Text(n["subtitle"], maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Text(n["time"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    onTap: () => _handleTap(n),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String title, String value) {
    final active = filter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => filter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.deepPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// PLACEHOLDERS — keep these
class ClientProgressScreen extends StatelessWidget {
  final String clientName;
  const ClientProgressScreen({required this.clientName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: Text("$clientName's Achievement"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, size: 120, color: Colors.amber[600]),
              const SizedBox(height: 32),
              Text(
                "Congratulations $clientName!",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "You just unlocked a massive milestone!\nKeep pushing — you're unstoppable!",
                style: TextStyle(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(clientName: clientName),
                    ),
                  );
                },
                icon: const Icon(Icons.message),
                label: const Text("Send a Message"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String clientName;
  const ChatScreen({required this.clientName, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late final List<Map<String, dynamic>> _messages = [
    {
      "text": "Hey coach! I just finished day 10 of the plan",
      "isSent": false,
      "time": "10:41 AM"
    },
    {
      "text": "That’s awesome ${widget.clientName.split(" ").first}! Keep crushing it!",
      "isSent": true,
      "time": "10:45 AM"
    },
    {
      "text": "Thanks! Feeling stronger already",
      "isSent": false,
      "time": "10:46 AM"
    },
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        "text": _controller.text.trim(),
        "isSent": true,
        "time": _formatTime(DateTime.now()),
      });
      _controller.clear();
    });

    // Auto-scroll to bottom when sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // You can add ScrollController later for smooth scroll
    });
  }

  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.clientName}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return msg["isSent"]
                    ? _buildSentMessage(msg["text"], msg["time"])
                    : _buildReceivedMessage(msg["text"], msg["time"]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(String text, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildSentMessage(String text, String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.deepPurple,
          borderRadius:  BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: const TextStyle(fontSize: 15, color: Colors.white)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: "unique_${DateTime.now().millisecondsSinceEpoch}",
            backgroundColor: Colors.deepPurple,
            onPressed: _sendMessage,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class SystemUpdateScreen extends StatelessWidget {
  const SystemUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("What's New"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(Icons.rocket_launch, size: 80, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "Version 2.4 - Trainer Pro",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "Released Today",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildFeature("New Chat System", "Real-time messaging with clients", Icons.chat_bubble),
            _buildFeature("Achievement Celebrations", "Congratulate clients with style", Icons.emoji_events),
            _buildFeature("Live Notification Badge", "Never miss an update", Icons.notifications_active),
            _buildFeature("Improved UI", "Smoother, faster, cleaner", Icons.design_services),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle),
                label: const Text("Got it! Take me back",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentIssueScreen extends StatelessWidget {
  final String clientName;
  const PaymentIssueScreen({required this.clientName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Payment Issue - $clientName"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Warning Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, size: 48, color: Colors.red.shade600),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Payment Failed", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text("Last attempt: 2 hours ago", style: TextStyle(color: Colors.grey[600])),
                        const Text("Amount: \$49.99", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 1. Send Reminder
            _buildActionButton(
              title: "Send Payment Reminder",
              icon: Icons.send,
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SendReminderScreen(clientName: clientName)),
              ),
            ),

            // 2. Update Payment Method
            _buildActionButton(
              title: "Update Payment Method",
              icon: Icons.credit_card,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UpdatePaymentScreen(clientName: clientName)),
              ),
            ),

            // 3. Pause Plan
            _buildActionButton(
              title: "Pause Client Plan",
              icon: Icons.pause_circle,
              color: Colors.red,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PausePlanScreen(clientName: clientName)),
              ),
            ),

            const Spacer(),
            Text(
              "Client will lose access in 3 days if not resolved",
              style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(title),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}

// 1. SEND PAYMENT REMINDER
class SendReminderScreen extends StatelessWidget {
  final String clientName;
  const SendReminderScreen({required this.clientName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reminder to $clientName")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.mark_email_unread, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text("Payment Reminder", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text("A friendly reminder will be sent via email & SMS", textAlign: TextAlign.center),
            const SizedBox(height: 32),
            const TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Add a personal note (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Reminder sent to $clientName!")),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 18),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Send Reminder Now", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. UPDATE PAYMENT METHOD
class UpdatePaymentScreen extends StatelessWidget {
  final String clientName;
  const UpdatePaymentScreen({required this.clientName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update $clientName's Card")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.credit_card, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text("Secure Payment Update", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("We’ll send a secure link to update their card"),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(child: Text("256-bit encrypted • Powered by Stripe")),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Secure payment link sent!")),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 18),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Send Update Link", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. PAUSE CLIENT PLAN
class PausePlanScreen extends StatelessWidget {
  final String clientName;
  const PausePlanScreen({required this.clientName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pause Plan")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.pause_circle, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text("Pause $clientName's Plan", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Client will keep progress but lose access until resumed"),
            const SizedBox(height: 32),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Reason for pause",
                border: OutlineInputBorder(),
              ),
              items: ["Payment Issue", "Taking a Break", "Injury", "Other"]
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (_) {},
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$clientName's plan paused")),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Pause Plan"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}