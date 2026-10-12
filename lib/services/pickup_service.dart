import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_bootstrap.dart';
import '../../models/pickup_request_model.dart';
import '../../models/collection_point_model.dart';

/// Service for pickup scheduling and collection point management
class PickupService {
  PickupService._();
  static final PickupService instance = PickupService._();

  static const String _pickupsCollection = 'pickup_requests';
  static const String _centersCollection = 'collection_points';

  final List<PickupRequest> _localPickups = _buildDefaultPickups();
  final List<CollectionPoint> _localCenters = CollectionPoint.defaultPoints;

  static List<PickupRequest> _buildDefaultPickups() {
    return [
      PickupRequest(
        id: 'pickup_001',
        userId: 'demo_user_001',
        disposalType: DisposalType.doorstepPickup,
        centerId: 'point_001',
        centerName: 'EcoCycler Central Hub',
        itemIds: ['item_001'],
        itemsSummary: 'Apple MacBook Pro 13" (2019)',
        pickupAddress: 'Flat 402, Green Meadows, Bengaluru, KA 560001',
        contactPhone: '+91 98765 43210',
        preferredDate: DateTime.now().add(const Duration(days: 1)),
        preferredTimeSlot: '10:00 AM – 01:00 PM',
        status: PickupStatus.assigned,
        collectorName: 'Rahul Sharma',
        collectorPhone: '+91 80421 88234',
        estimatedGreenCredits: 180,
        estimatedWeightKg: 1.4,
        notes: 'Gate code: 4421. Please call upon arrival.',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }

  // ──────────────────── Pickup Requests ────────────────────

  Future<List<PickupRequest>> fetchPickupsForUser(String userId) async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection(_pickupsCollection)
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
        return query.docs
            .map((doc) => PickupRequest.fromMap(doc.data(), doc.id))
            .toList();
      } catch (e) {
        debugPrint('[W2V:PickupService] fetchPickups error: $e');
      }
    }
    return _localPickups.where((p) => p.userId == userId).toList();
  }

  Future<PickupRequest> schedulePickup(PickupRequest request) async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        final ref = await FirebaseFirestore.instance
            .collection(_pickupsCollection)
            .add(request.toMap());
        final saved = PickupRequest.fromMap(request.toMap(), ref.id);
        _localPickups.insert(0, saved);
        return saved;
      } catch (e) {
        debugPrint('[W2V:PickupService] schedulePickup Firestore error: $e');
      }
    }
    _localPickups.insert(0, request);
    return request;
  }

  Future<void> updatePickupStatus(String pickupId, PickupStatus newStatus) async {
    final idx = _localPickups.indexWhere((p) => p.id == pickupId);
    if (idx != -1) {
      final old = _localPickups[idx];
      _localPickups[idx] = PickupRequest(
        id: old.id,
        userId: old.userId,
        disposalType: old.disposalType,
        centerId: old.centerId,
        centerName: old.centerName,
        itemIds: old.itemIds,
        itemsSummary: old.itemsSummary,
        pickupAddress: old.pickupAddress,
        contactPhone: old.contactPhone,
        preferredDate: old.preferredDate,
        preferredTimeSlot: old.preferredTimeSlot,
        status: newStatus,
        collectorName: old.collectorName,
        collectorPhone: old.collectorPhone,
        estimatedGreenCredits: old.estimatedGreenCredits,
        estimatedWeightKg: old.estimatedWeightKg,
        notes: old.notes,
        createdAt: old.createdAt,
      );
    }
    if (FirebaseBootstrap.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_pickupsCollection)
            .doc(pickupId)
            .update({'status': newStatus.name});
      } catch (e) {
        debugPrint('[W2V:PickupService] updatePickupStatus error: $e');
      }
    }
  }

  // ──────────────────── Collection Points ────────────────────

  Future<List<CollectionPoint>> fetchCollectionPoints() async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection(_centersCollection)
            .get();
        if (query.docs.isNotEmpty) {
          return query.docs
              .map((doc) => CollectionPoint.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('[W2V:PickupService] fetchCollectionPoints error: $e');
      }
    }
    return List.from(_localCenters);
  }

  Future<CollectionPoint?> fetchCollectionPointById(String id) async {
    final points = await fetchCollectionPoints();
    try {
      return points.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
