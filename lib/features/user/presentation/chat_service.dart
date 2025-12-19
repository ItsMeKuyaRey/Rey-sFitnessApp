// lib/core/services/chat_service.dart
// 🔥 FIXED - Handles non-existent documents properly

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate unique chat ID between two users
  static String getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  // Send message (works for BOTH user and trainer)
  static Future<void> sendMessage({
    required String receiverId,
    required String message,
    String? senderName,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || message.trim().isEmpty) return;

    final chatId = getChatId(currentUser.uid, receiverId);

    try {
      // Add message to chat
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'message': message.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Update chat metadata (create if doesn't exist)
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [currentUser.uid, receiverId],
        'lastMessage': message.trim(),
        'lastMessageBy': currentUser.uid,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount_${receiverId}': FieldValue.increment(1),
      }, SetOptions(merge: true));

      print('✅ Message sent successfully!');
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  // Get messages stream (REAL-TIME updates!)
  static Stream<QuerySnapshot> getMessages(String otherUserId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    final chatId = getChatId(currentUser.uid, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // 🔥 FIXED: Mark messages as read (handles non-existent docs)
  static Future<void> markAsRead(String otherUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final chatId = getChatId(currentUser.uid, otherUserId);

    try {
      // Check if chat document exists first
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (chatDoc.exists) {
        // Only update if document exists
        await _firestore.collection('chats').doc(chatId).update({
          'unreadCount_${currentUser.uid}': 0,
        });
      } else {
        // Document doesn't exist yet - that's okay, no messages to mark as read
        print('ℹ️ Chat document not found - no messages to mark as read yet');
      }
    } catch (e) {
      print('Error marking as read: $e');
      // Don't rethrow - this is not a critical error
    }
  }

  // Get unread count
  static Stream<int> getUnreadCount() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.value(0);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        total += (data['unreadCount_${currentUser.uid}'] as int?) ?? 0;
      }
      return total;
    });
  }
}
