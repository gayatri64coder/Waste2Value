/// Typed notification categories
enum NotificationType {
  pickupUpdate,
  creditsEarned,
  passportReady,
  rewardRedeemed,
  systemAlert,
  ecoTip;

  static NotificationType fromString(String raw) {
    return switch (raw) {
      'pickup_update' => NotificationType.pickupUpdate,
      'credits_awarded' || 'credits_earned' => NotificationType.creditsEarned,
      'passport_ready' => NotificationType.passportReady,
      'reward_redeemed' => NotificationType.rewardRedeemed,
      'system_alert' => NotificationType.systemAlert,
      _ => NotificationType.ecoTip,
    };
  }
}

/// AppNotification model representing in-app and push notification alerts
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime timestamp;
  final String? route;
  final Map<String, dynamic>? metadata;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.timestamp,
    this.route,
    this.metadata,
  });

  /// Alias so screens can use either `.message` or `.body`
  String get body => message;

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    DateTime? timestamp,
    String? route,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      route: route ?? this.route,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
      'route': route,
      'metadata': metadata,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      userId: map['userId'] as String? ?? 'user_default',
      title: map['title'] as String? ?? 'Eco Notification',
      message: map['message'] as String? ?? '',
      type: NotificationType.fromString(map['type'] as String? ?? 'eco_tip'),
      isRead: map['isRead'] as bool? ?? false,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      route: map['route'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  static List<AppNotification> defaultNotifications = [
    AppNotification(
      id: 'notif_001',
      userId: 'demo_user_001',
      title: 'Pickup Confirmed! 🚚',
      message:
          'Eco Agent Rahul Sharma has been assigned to your pickup tomorrow at 10:00 AM.',
      type: NotificationType.pickupUpdate,
      isRead: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      route: '/tracking',
    ),
    AppNotification(
      id: 'notif_002',
      userId: 'demo_user_001',
      title: 'Green Credits Awarded! 🌱 +85',
      message:
          'Samsung Galaxy S20 verified at Indiranagar Recovery Kiosk. 85 credits added.',
      type: NotificationType.creditsEarned,
      isRead: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      route: '/rewards',
    ),
    AppNotification(
      id: 'notif_003',
      userId: 'demo_user_001',
      title: 'Digital Product Passport Ready 📜',
      message:
          'Passport #W2V-2026-90412 for MacBook Pro 13" is now on the circular ledger.',
      type: NotificationType.passportReady,
      isRead: true,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      route: '/ewaste-passport',
    ),
  ];
}

typedef NotificationModel = AppNotification;
