/// Status of pickup or drop-off lifecycle
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

/// Type of disposal logistics
enum DisposalType {
  doorstepPickup('Doorstep Pickup'),
  centerDropoff('Drop-off at Certified Center');

  final String label;
  const DisposalType(this.label);

  static DisposalType fromString(String? val) {
    if (val?.toLowerCase() == 'centerdropoff') return DisposalType.centerDropoff;
    return DisposalType.doorstepPickup;
  }
}

/// PickupRequest model representing a scheduled doorstep collection or drop-off booking
class PickupRequest {
  final String id;
  final String userId;
  final DisposalType disposalType;
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
  final String? notes;
  final DateTime createdAt;

  const PickupRequest({
    required this.id,
    required this.userId,
    this.disposalType = DisposalType.doorstepPickup,
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
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'disposalType': disposalType.name,
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
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PickupRequest.fromMap(Map<String, dynamic> map, String id) {
    return PickupRequest(
      id: id,
      userId: map['userId'] as String? ?? 'user_default',
      disposalType: DisposalType.fromString(map['disposalType'] as String?),
      centerId: map['centerId'] as String? ?? 'center_001',
      centerName: map['centerName'] as String? ?? 'EcoCycler Central Hub',
      itemIds: (map['itemIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      itemsSummary: map['itemsSummary'] as String? ?? 'Electronic devices for circular recycling',
      pickupAddress: map['pickupAddress'] as String? ?? 'User Default Address',
      contactPhone: map['contactPhone'] as String? ?? '+91 98765 43210',
      preferredDate: map['preferredDate'] != null
          ? DateTime.tryParse(map['preferredDate'].toString()) ?? DateTime.now().add(const Duration(days: 1))
          : DateTime.now().add(const Duration(days: 1)),
      preferredTimeSlot: map['preferredTimeSlot'] as String? ?? '10:00 AM - 01:00 PM',
      status: PickupStatus.fromString(map['status'] as String?),
      collectorName: map['collectorName'] as String?,
      collectorPhone: map['collectorPhone'] as String?,
      estimatedGreenCredits: (map['estimatedGreenCredits'] as num?)?.toInt() ?? 80,
      estimatedWeightKg: (map['estimatedWeightKg'] as num?)?.toDouble() ?? 2.5,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
