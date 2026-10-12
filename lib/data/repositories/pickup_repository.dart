import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_bootstrap.dart';
import '../../domain/models/pickup_request.dart';

/// Repository for scheduling and tracking doorstep e-waste pickups.
class PickupRepository extends ChangeNotifier {
  static final PickupRepository _instance = PickupRepository._internal();
  factory PickupRepository() => _instance;
  PickupRepository._internal() {
    _initSeeds();
  }

  final List<PickupRequest> _pickups = [];
  List<PickupRequest> get pickups => List.unmodifiable(_pickups);

  void _initSeeds() {
    _pickups.add(
      PickupRequest(
        id: 'pk_1001',
        userId: 'demo_user_001',
        centerId: 'center_001',
        centerName: 'EcoCycler Certified R2 Hub - Whitefield',
        itemIds: const ['item_001'],
        itemsSummary: '1x Apple MacBook Pro 13" (2019)',
        pickupAddress: 'Flat 402, Green Meadows, Bengaluru, KA',
        contactPhone: '+91 98765 43210',
        preferredDate: DateTime.now().add(const Duration(days: 1)),
        preferredTimeSlot: '10:00 AM - 01:00 PM',
        status: PickupStatus.assigned,
        collectorName: 'Rajesh Kumar (Verified Badge #84)',
        collectorPhone: '+91 98111 22334',
        estimatedGreenCredits: 180,
        estimatedWeightKg: 1.4,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        timeline: [
          TrackingMilestone(
            title: 'Pickup Requested',
            description: 'Item details and preferred slot submitted.',
            timestamp: DateTime.now().subtract(const Duration(hours: 6)),
            isCompleted: true,
          ),
          TrackingMilestone(
            title: 'Collector Assigned',
            description: 'Rajesh Kumar from EcoCycler Hub assigned.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isCompleted: true,
          ),
          TrackingMilestone(
            title: 'En Route & Collection',
            description: 'Agent arrives with antistatic transport container.',
            timestamp: DateTime.now().add(const Duration(hours: 18)),
            isCompleted: false,
          ),
          TrackingMilestone(
            title: 'Hub Inspection & Credits Issued',
            description: 'Material certified and Green Credits deposited.',
            timestamp: DateTime.now().add(const Duration(hours: 24)),
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  /// Schedule a new doorstep pickup
  Future<PickupRequest> schedulePickup({
    required String userId,
    required String centerId,
    required String centerName,
    required List<String> itemIds,
    required String itemsSummary,
    required String pickupAddress,
    required String contactPhone,
    required DateTime preferredDate,
    required String preferredTimeSlot,
    required int estimatedCredits,
    required double estimatedWeight,
  }) async {
    final newPickup = PickupRequest(
      id: 'pk_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      centerId: centerId,
      centerName: centerName,
      itemIds: itemIds,
      itemsSummary: itemsSummary,
      pickupAddress: pickupAddress,
      contactPhone: contactPhone,
      preferredDate: preferredDate,
      preferredTimeSlot: preferredTimeSlot,
      status: PickupStatus.requested,
      estimatedGreenCredits: estimatedCredits,
      estimatedWeightKg: estimatedWeight,
      createdAt: DateTime.now(),
      timeline: [
        TrackingMilestone(
          title: 'Pickup Requested',
          description: 'Request received and queued for dispatch.',
          timestamp: DateTime.now(),
          isCompleted: true,
        ),
        TrackingMilestone(
          title: 'Collector Assigned',
          description: 'Verifying nearest agent route.',
          timestamp: DateTime.now(),
          isCompleted: false,
        ),
      ],
    );

    if (FirebaseBootstrap.isInitialized) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('pickup_requests')
            .add(newPickup.toMap());
        final saved = PickupRequest.fromMap(newPickup.toMap(), doc.id);
        _pickups.insert(0, saved);
        notifyListeners();
        return saved;
      } catch (e) {
        debugPrint('[waste2value] Firestore pickup error: $e');
      }
    }

    _pickups.insert(0, newPickup);
    notifyListeners();
    return newPickup;
  }
}
