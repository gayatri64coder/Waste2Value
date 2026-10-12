/// TrackingEvent model representing custody transfers and processing milestones
class TrackingEvent {
  final String id;
  final String trackingId;
  final String title;
  final String description;
  final DateTime timestamp;
  final String location;
  final String status;
  final String? actorName;
  final String? actorRole;
  final bool isCompleted;

  const TrackingEvent({
    required this.id,
    required this.trackingId,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.location,
    required this.status,
    this.actorName,
    this.actorRole,
    this.isCompleted = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackingId': trackingId,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'status': status,
      'actorName': actorName,
      'actorRole': actorRole,
      'isCompleted': isCompleted,
    };
  }

  factory TrackingEvent.fromMap(Map<String, dynamic> map, String id) {
    return TrackingEvent(
      id: id,
      trackingId: map['trackingId'] as String? ?? 'track_default',
      title: map['title'] as String? ?? 'Milestone Event',
      description: map['description'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      location: map['location'] as String? ?? 'Collection Hub',
      status: map['status'] as String? ?? 'Completed',
      actorName: map['actorName'] as String?,
      actorRole: map['actorRole'] as String?,
      isCompleted: map['isCompleted'] as bool? ?? true,
    );
  }
}
