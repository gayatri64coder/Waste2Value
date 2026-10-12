enum PickupStatus {
  requested('Request Submitted', '📋'),
  assigned('Agent Assigned', '👤'),
  collectorEnRoute('Collector En Route', '🚚'),
  collected('Items Collected', '📦'),
  inspected('Weighed & Certified', '⚖️'),
  completed('Credits Issued', '✅'),
  cancelled('Cancelled', '❌');

  final String label;
  final String icon;
  const PickupStatus(this.label, this.icon);

  static PickupStatus fromString(String? val) {
    for (var s in PickupStatus.values) {
      if (s.name.toLowerCase() == val?.toLowerCase()) return s;
    }
    return PickupStatus.requested;
  }
}

class TrackingMilestone {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  const TrackingMilestone({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory TrackingMilestone.fromMap(Map<String, dynamic> map) {
    return TrackingMilestone(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}

class PickupRequest {
  final String id;
  final String userId;
  final String centerId;
  final String centerName;
  final List<String> itemIds;
  final String itemsSummary;
  final String pickupAddress;
  final String contactPhone;
  final DateTime preferredDate;
  final String preferredTimeSlot;
  final PickupStatus status;
  final String? collectorName;
  final String? collectorPhone;
  final int estimatedGreenCredits;
  final double estimatedWeightKg;
  final DateTime createdAt;
  final List<TrackingMilestone> timeline;

  const PickupRequest({
    required this.id,
    required this.userId,
    required this.centerId,
    required this.centerName,
    required this.itemIds,
    required this.itemsSummary,
    required this.pickupAddress,
    required this.contactPhone,
    required this.preferredDate,
    required this.preferredTimeSlot,
    required this.status,
    this.collectorName,
    this.collectorPhone,
    required this.estimatedGreenCredits,
    required this.estimatedWeightKg,
    required this.createdAt,
    required this.timeline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'centerId': centerId,
      'centerName': centerName,
      'itemIds': itemIds,
      'itemsSummary': itemsSummary,
      'pickupAddress': pickupAddress,
      'contactPhone': contactPhone,
      'preferredDate': preferredDate.toIso8601String(),
      'preferredTimeSlot': preferredTimeSlot,
      'status': status.name,
      'collectorName': collectorName,
      'collectorPhone': collectorPhone,
      'estimatedGreenCredits': estimatedGreenCredits,
      'estimatedWeightKg': estimatedWeightKg,
      'createdAt': createdAt.toIso8601String(),
      'timeline': timeline.map((e) => e.toMap()).toList(),
    };
  }

  factory PickupRequest.fromMap(Map<String, dynamic> map, String id) {
    final rawMilestones = (map['timeline'] as List<dynamic>?)
            ?.map((e) =>
                TrackingMilestone.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PickupRequest(
      id: id,
      userId: map['userId'] as String? ?? 'user_default',
      centerId: map['centerId'] as String? ?? 'center_default',
      centerName: map['centerName'] as String? ?? 'Eco Central Facility',
      itemIds: (map['itemIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      itemsSummary: map['itemsSummary'] as String? ?? '1x Device for recycling',
      pickupAddress: map['pickupAddress'] as String? ?? 'Standard Address',
      contactPhone: map['contactPhone'] as String? ?? '+91 98765 43210',
      preferredDate: map['preferredDate'] != null
          ? DateTime.tryParse(map['preferredDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      preferredTimeSlot:
          map['preferredTimeSlot'] as String? ?? '10:00 AM - 01:00 PM',
      status: PickupStatus.fromString(map['status'] as String?),
      collectorName: map['collectorName'] as String?,
      collectorPhone: map['collectorPhone'] as String?,
      estimatedGreenCredits:
          (map['estimatedGreenCredits'] as num?)?.toInt() ?? 50,
      estimatedWeightKg:
          (map['estimatedWeightKg'] as num?)?.toDouble() ?? 2.0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      timeline: rawMilestones,
    );
  }
}
