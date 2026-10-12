import 'package:flutter/foundation.dart';
import '../services/pickup_service.dart';
import '../models/pickup_request_model.dart';
import '../models/collection_point_model.dart';

/// Provider for pickup requests and collection point state
class PickupProvider extends ChangeNotifier {
  final PickupService _service;
  List<PickupRequest> _pickups = [];
  List<CollectionPoint> _centers = [];
  bool _isLoading = false;
  String? _error;

  PickupProvider({PickupService? service})
      : _service = service ?? PickupService.instance;

  List<PickupRequest> get pickups => List.unmodifiable(_pickups);
  List<CollectionPoint> get centers => List.unmodifiable(_centers);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<PickupRequest> get activePickups => _pickups
      .where((p) =>
          p.status != PickupStatus.completed &&
          p.status != PickupStatus.cancelled)
      .toList();

  Future<void> loadPickupsForUser(String userId) async {
    _setLoading(true);
    _error = null;
    try {
      _pickups = await _service.fetchPickupsForUser(userId);
    } catch (e) {
      _error = 'Failed to load pickups. $e';
    }
    _setLoading(false);
  }

  Future<void> loadCollectionPoints() async {
    _setLoading(true);
    _error = null;
    try {
      _centers = await _service.fetchCollectionPoints();
    } catch (e) {
      _error = 'Failed to load collection points. $e';
    }
    _setLoading(false);
  }

  Future<PickupRequest?> schedulePickup(PickupRequest request) async {
    _error = null;
    try {
      final saved = await _service.schedulePickup(request);
      _pickups.insert(0, saved);
      notifyListeners();
      return saved;
    } catch (e) {
      _error = 'Failed to schedule pickup. $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> updateStatus(String pickupId, PickupStatus status) async {
    await _service.updatePickupStatus(pickupId, status);
    final idx = _pickups.indexWhere((p) => p.id == pickupId);
    if (idx != -1) {
      final old = _pickups[idx];
      _pickups[idx] = PickupRequest(
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
        status: status,
        collectorName: old.collectorName,
        collectorPhone: old.collectorPhone,
        estimatedGreenCredits: old.estimatedGreenCredits,
        estimatedWeightKg: old.estimatedWeightKg,
        notes: old.notes,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
