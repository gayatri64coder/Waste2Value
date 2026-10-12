import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_bootstrap.dart';
import '../../models/notification_model.dart';

/// Service for in-app notifications
class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  static const String _collection = 'notifications';

  final List<AppNotification> _localNotifications =
      List.from(AppNotification.defaultNotifications);

  /// Fetch notifications for user
  Future<List<AppNotification>> fetchForUser(String userId) async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection(_collection)
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .get();
        return query.docs
            .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
            .toList();
      } catch (e) {
        debugPrint('[W2V:NotificationsService] fetchForUser error: $e');
      }
    }
    return _localNotifications.where((n) => n.userId == userId).toList();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final idx = _localNotifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _localNotifications[idx] = _localNotifications[idx].copyWith(isRead: true);
    }
    if (FirebaseBootstrap.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_collection)
            .doc(notificationId)
            .update({'isRead': true});
      } catch (e) {
        debugPrint('[W2V:NotificationsService] markAsRead error: $e');
      }
    }
  }

  /// Mark all as read for user
  Future<void> markAllAsRead(String userId) async {
    for (int i = 0; i < _localNotifications.length; i++) {
      if (_localNotifications[i].userId == userId) {
        _localNotifications[i] = _localNotifications[i].copyWith(isRead: true);
      }
    }
    if (FirebaseBootstrap.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection(_collection)
            .where('userId', isEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in query.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      } catch (e) {
        debugPrint('[W2V:NotificationsService] markAllAsRead error: $e');
      }
    }
  }

  /// Push a new notification locally (and to Firestore)
  Future<void> pushNotification(AppNotification notification) async {
    _localNotifications.insert(0, notification);
    if (FirebaseBootstrap.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_collection)
            .add(notification.toMap());
      } catch (e) {
        debugPrint('[W2V:NotificationsService] push error: $e');
      }
    }
  }

  int countUnread(String userId) {
    return _localNotifications
        .where((n) => n.userId == userId && !n.isRead)
        .length;
  }
}
