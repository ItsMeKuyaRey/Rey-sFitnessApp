// lib/features/user/presentation/user_chat_screen.dart
// 🔥 FIXED - User pretends to be "Sarah Johnson" (client_001) to test trainer chat

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import 'chat_service.dart';

// --- Theme Constants ---
const Color backgroundLight = Color(0xFFF5F5F5);
const Color backgroundDark = Color(0xFF121212);
const Color inputFieldLight = Color(0xFFEFEFEF);
const Color inputFieldDark = Color(0xFF333333);
const Color bubbleOtherLight = Colors.white;
const Color bubbleOtherDark = Color(0xFF212121);
const Color textDark = Color(0xFF333333);
const Color textLight = Colors.white;

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 🔥 TRAINER INFO - Real trainer Firebase UID
  final String trainerId = "AcM1SESP9WaOTdwjGnyeub4E6ZG3";
  final String trainerName = "David Thompson";
  final String trainerRole = "Personal Trainer";
  final String trainerAvatar = "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400";

  // 🔥 NEW: User simulates being Sarah Johnson (client_001)
  // This allows the user app to receive messages sent to Sarah
  final String simulatedClientId = "client_001"; // Sarah Johnson
  final String simulatedClientName = "Sarah Johnson";

  @override
  void initState() {
    super.initState();
    // Note: We don't call markAsRead for dummy clients since they're not real Firebase users
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animate: false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  // 🔥 CUSTOM SEND: Send as dummy client (not using Firebase Auth)
  Future<void> _sendMessageAsClient() async {
    if (_controller.text.trim().isEmpty) return;

    final message = _controller.text.trim();
    _controller.clear();
    _scrollToBottom();

    final chatId = ChatService.getChatId(trainerId, simulatedClientId);

    try {
      final firestore = FirebaseFirestore.instance;

      // Add message
      await firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': simulatedClientId, // 🔥 Send as Sarah
        'receiverId': trainerId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Update chat metadata
      await firestore.collection('chats').doc(chatId).set({
        'participants': [trainerId, simulatedClientId],
        'lastMessage': message,
        'lastMessageBy': simulatedClientId,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount_$trainerId': FieldValue.increment(1),
      }, SetOptions(merge: true));

      print('✅ Message sent as $simulatedClientName!');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🔥 CUSTOM STREAM: Listen to messages between trainer and Sarah
  Stream<QuerySnapshot> _getMessagesAsClient() {
    final chatId = ChatService.getChatId(trainerId, simulatedClientId);

    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = isDark ? backgroundDark : backgroundLight;
    final bubbleColorOther = isDark ? bubbleOtherDark : bubbleOtherLight;
    final inputFillColor = isDark ? inputFieldDark : inputFieldLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(trainerAvatar),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trainerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    trainerRole,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 🔥 Show which client we're simulating
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "As: $simulatedClientName",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "You're chatting as Sarah Johnson (client_001)",
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔥 MESSAGES STREAM - Custom for dummy client
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMessagesAsClient(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading messages',
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          "No messages yet",
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const Text(
                          "Start the conversation!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final bool isNearBottom = !_scrollController.hasClients ||
                      (_scrollController.position.maxScrollExtent - _scrollController.offset).abs() < 100;

                  if (isNearBottom) {
                    _scrollToBottom();
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final doc = messages[index];
                    final data = doc.data() as Map<String, dynamic>?;

                    if (data == null) return const SizedBox.shrink();

                    final senderId = data['senderId'] as String? ?? '';
                    final message = data['message'] as String? ?? '';
                    final timestamp = data['timestamp'] as Timestamp?;

                    if (message.isEmpty) return const SizedBox.shrink();

                    // 🔥 Message is "mine" if sent by Sarah (simulatedClientId)
                    final isMe = senderId == simulatedClientId;

                    return _MessageBubble(
                      message: message,
                      isMe: isMe,
                      timestamp: timestamp,
                      bubbleColor: bubbleColorOther,
                      isDark: isDark,
                    );
                  },
                );
              },
            ),
          ),

          // INPUT BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: bubbleColorOther,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        color: isDark ? textLight : textDark,
                      ),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade700,
                        ),
                        filled: true,
                        fillColor: inputFillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessageAsClient(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.deepPurple,
                    elevation: 2,
                    heroTag: 'user_send_${DateTime.now().millisecondsSinceEpoch}',
                    onPressed: _sendMessageAsClient,
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final Timestamp? timestamp;
  final Color bubbleColor;
  final bool isDark;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.timestamp,
    required this.bubbleColor,
    required this.isDark,
  });

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.deepPurple
              : (isDark ? bubbleOtherDark : bubbleColor),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
                fontSize: 15,
              ),
            ),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatTime(timestamp),
                style: TextStyle(
                  color: isMe
                      ? Colors.white70
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
