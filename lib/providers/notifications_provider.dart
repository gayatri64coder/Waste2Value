import 'package:flutter/foundation.dart';
import '../services/notifications_service.dart';
import '../models/notification_model.dart';

/// Provider for app notifications state
class NotificationsProvider extends ChangeNotifier {
  final NotificationsService _service;
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  NotificationsProvider({NotificationsService? service})
      : _service = service ?? NotificationsService.instance;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  Future<void> loadForUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _service.fetchForUser(userId);
    } catch (e) {
      debugPrint('[W2V:NotificationsProvider] load error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    await _service.markAllAsRead(userId);
    _notifications = _notifications
        .map((n) => n.userId == userId ? n.copyWith(isRead: true) : n)
        .toList();
    notifyListeners();
  }
}
