import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/auth_provider.dart';

class NotificationsService {
  final FirebaseFirestore _firestore;
  final String? _userId;

  NotificationsService(this._firestore, this._userId);

  //create notification
  Future<void> createNotification({
    required String recipientId,
    required String type,
    //here 'like', 'comment', 'follow'
    required String message,
    String? postId,
    String? senderId,
    String? senderUsername,
  }) async {
    if (_userId == null) return;
    if (recipientId == _userId) return;
    //don't notify yourself

    try {
      await _firestore.collection('Notifications').add({
        'recipientId': recipientId,
        'senderId': senderId ?? _userId,
        'senderUsername': senderUsername ?? 'Someone',
        'type': type,
        'message': message,
        'postId': postId,
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  //mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('Notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  //mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_userId == null) return;

    try {
      final unreadNotifications = await _firestore
          .collection('Notifications')
          .where('recipientId', isEqualTo: _userId)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in unreadNotifications.docs) {
        await doc.reference.update({'read': true});
      }
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  //delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('Notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  //get notifications stream
  Stream<QuerySnapshot> getNotificationsStream() {
    if (_userId == null) return Stream.value(FirebaseFirestore.instance.collection('Notifications').snapshots() as QuerySnapshot);

    return _firestore
        .collection('Notifications')
        .where('recipientId', isEqualTo: _userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  //get unread count
  Stream<int> getUnreadCount() {
    if (_userId == null) return Stream.value(0);

    return _firestore
        .collection('Notifications')
        .where('recipientId', isEqualTo: _userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

//provider
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  final firestore = FirebaseFirestore.instance;
  final authState = ref.watch(authStateProvider);

  String? userId;
  authState.whenData((user) {
    userId = user?.uid;
  });

  return NotificationsService(firestore, userId);
});

//stream provider for notifications
final notificationsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  final service = ref.watch(notificationsServiceProvider);
  return service.getNotificationsStream();
});

//stream provider for unread count
final unreadCountProvider = StreamProvider<int>((ref) {
  final service = ref.watch(notificationsServiceProvider);
  return service.getUnreadCount();
});