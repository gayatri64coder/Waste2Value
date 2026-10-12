import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_bootstrap.dart';
import '../../domain/models/ewaste_item.dart';

/// Repository for managing electronic waste assets and listings.
class EwasteRepository extends ChangeNotifier {
  static final EwasteRepository _instance = EwasteRepository._internal();
  factory EwasteRepository() => _instance;
  EwasteRepository._internal() {
    _initLocalSeeds();
  }

  final List<EwasteItem> _items = [];
  bool _isLoading = false;

  List<EwasteItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  void _initLocalSeeds() {
    _items.addAll([
      EwasteItem(
        id: 'item_001',
        userId: 'demo_user_001',
        title: 'Apple MacBook Pro 13" (2019)',
        category: DeviceCategory.laptop,
        brand: 'Apple',
        model: 'A2159 Core i5 256GB',
        purchaseYear: 2019,
        condition: DeviceCondition.good,
        functionalStatus: FunctionalStatus.working,
        estimatedValue: 245.0,
        carbonSavedKg: 42.0,
        weightKg: 1.4,
        preciousMetals: const PreciousMetalsEstimate(
          goldGrams: 0.18,
          silverGrams: 1.20,
          copperGrams: 420.0,
          palladiumGrams: 0.05,
        ),
        greenCreditsEarned: 180,
        status: EwasteStatus.scheduled,
        recommendedAction: 'Refurbish & Reuse (Eligible for Max Credits)',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      EwasteItem(
        id: 'item_002',
        userId: 'demo_user_001',
        title: 'Samsung Galaxy S20 (Cracked Screen)',
        category: DeviceCategory.smartphone,
        brand: 'Samsung',
        model: 'SM-G981B',
        purchaseYear: 2020,
        condition: DeviceCondition.crackedScreen,
        functionalStatus: FunctionalStatus.working,
        estimatedValue: 68.0,
        carbonSavedKg: 16.5,
        weightKg: 0.18,
        preciousMetals: const PreciousMetalsEstimate(
          goldGrams: 0.034,
          silverGrams: 0.35,
          copperGrams: 15.0,
          palladiumGrams: 0.015,
        ),
        greenCreditsEarned: 85,
        status: EwasteStatus.listed,
        recommendedAction: 'Component Harvesting (Motherboard & Camera Intact)',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      EwasteItem(
        id: 'item_003',
        userId: 'demo_user_001',
        title: 'Dell Optiplex 7050 Motherboard & CPU',
        category: DeviceCategory.circuitBoard,
        brand: 'Dell',
        model: 'LGA1151 Desktop PCB',
        purchaseYear: 2017,
        condition: DeviceCondition.brokenOrDamaged,
        functionalStatus: FunctionalStatus.dead,
        estimatedValue: 32.5,
        carbonSavedKg: 28.0,
        weightKg: 0.85,
        preciousMetals: const PreciousMetalsEstimate(
          goldGrams: 0.22,
          silverGrams: 1.10,
          copperGrams: 310.0,
          palladiumGrams: 0.04,
        ),
        greenCreditsEarned: 60,
        status: EwasteStatus.recycled,
        recommendedAction: 'Certified Precious Metal Smelting',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ]);
  }

  /// Fetch all e-waste items for current user
  Future<List<EwasteItem>> fetchItems() async {
    _isLoading = true;
    notifyListeners();

    if (FirebaseBootstrap.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection('ewaste_items')
            .orderBy('createdAt', descending: true)
            .get();

        _items.clear();
        for (var doc in query.docs) {
          _items.add(EwasteItem.fromMap(doc.data(), doc.id));
        }
        _isLoading = false;
        notifyListeners();
        return _items;
      } catch (e) {
        debugPrint('[waste2value] Firestore fetch error: $e. Using local cache.');
      }
    }

    _isLoading = false;
    notifyListeners();
    return _items;
  }

  /// Add new e-waste listing
  Future<EwasteItem> addItem(EwasteItem item) async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        final docRef = await FirebaseFirestore.instance
            .collection('ewaste_items')
            .add(item.toMap());
        final savedItem = EwasteItem.fromMap(item.toMap(), docRef.id);
        _items.insert(0, savedItem);
        notifyListeners();
        return savedItem;
      } catch (e) {
        debugPrint('[waste2value] Firestore add error: $e');
      }
    }

    // Local fallback
    _items.insert(0, item);
    notifyListeners();
    return item;
  }

  /// Update listing status (e.g., Scheduled, Picked Up, Recycled)
  Future<void> updateStatus(String itemId, EwasteStatus newStatus) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      final old = _items[index];
      final updated = EwasteItem(
        id: old.id,
        userId: old.userId,
        title: old.title,
        category: old.category,
        brand: old.brand,
        model: old.model,
        purchaseYear: old.purchaseYear,
        condition: old.condition,
        functionalStatus: old.functionalStatus,
        estimatedValue: old.estimatedValue,
        carbonSavedKg: old.carbonSavedKg,
        weightKg: old.weightKg,
        preciousMetals: old.preciousMetals,
        greenCreditsEarned: old.greenCreditsEarned,
        status: newStatus,
        recommendedAction: old.recommendedAction,
        createdAt: old.createdAt,
        serialOrImei: old.serialOrImei,
        notes: old.notes,
      );
      _items[index] = updated;
      notifyListeners();

      if (FirebaseBootstrap.isInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('ewaste_items')
              .doc(itemId)
              .update({'status': newStatus.name});
        } catch (e) {
          debugPrint('[waste2value] Firestore updateStatus error: $e');
        }
      }
    }
  }
}
