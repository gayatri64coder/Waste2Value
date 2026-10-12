import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_bootstrap.dart';
import '../../models/ewaste_item_model.dart';

/// Service abstracting all Firestore operations for e-waste items
class EWasteService {
  static const String _collection = 'ewaste_items';

  EWasteService._();
  static final EWasteService instance = EWasteService._();

  final List<EWasteItem> _localCache = _buildDefaultSeeds();

  static List<EWasteItem> _buildDefaultSeeds() {
    return [
      EWasteItem(
        id: 'item_001',
        userId: 'demo_user_001',
        title: 'Apple MacBook Pro 13" (2019)',
        categoryId: 'cat_laptops',
        categoryName: 'Laptops & Computers',
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
        status: EwasteStatus.pickupScheduled,
        recommendedAction: 'Refurbish & Reuse — Eligible for Maximum Credits',
        serialNumber: 'C02XL8A1MD6R',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      EWasteItem(
        id: 'item_002',
        userId: 'demo_user_001',
        title: 'Samsung Galaxy S20 (Cracked Screen)',
        categoryId: 'cat_smartphones',
        categoryName: 'Smartphones & Tablets',
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
        status: EwasteStatus.submitted,
        recommendedAction: 'Component Harvesting — Motherboard & Camera Intact',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      EWasteItem(
        id: 'item_003',
        userId: 'demo_user_001',
        title: 'Dell Optiplex 7050 Motherboard & CPU',
        categoryId: 'cat_pcbs',
        categoryName: 'PCBs & Motherboards',
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
        recommendedAction: 'Certified Precious Metal Hydrometallurgical Smelting',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ];
  }

  /// Fetch items for a specific user
  Future<List<EWasteItem>> fetchItemsForUser(String userId) async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection(_collection)
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

        return query.docs.map((doc) => EWasteItem.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        debugPrint('[W2V:EWasteService] fetchItems error: $e — using local cache');
      }
    }
    return _localCache.where((item) => item.userId == userId).toList();
  }

  /// Fetch all items (admin/reviewer use)
  Future<List<EWasteItem>> fetchAllItems() async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection(_collection)
            .orderBy('createdAt', descending: true)
            .get();
        return query.docs.map((doc) => EWasteItem.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        debugPrint('[W2V:EWasteService] fetchAllItems error: $e');
      }
    }
    return List.from(_localCache);
  }

  /// Add a new e-waste item
  Future<EWasteItem> addItem(EWasteItem item) async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        final docRef = await FirebaseFirestore.instance
            .collection(_collection)
            .add(item.toMap());
        final saved = EWasteItem.fromMap(item.toMap(), docRef.id);
        _localCache.insert(0, saved);
        return saved;
      } catch (e) {
        debugPrint('[W2V:EWasteService] addItem Firestore error: $e — local only');
      }
    }
    _localCache.insert(0, item);
    return item;
  }

  /// Update item status
  Future<void> updateStatus(String itemId, EwasteStatus newStatus) async {
    final idx = _localCache.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      final old = _localCache[idx];
      _localCache[idx] = EWasteItem(
        id: old.id,
        userId: old.userId,
        title: old.title,
        categoryId: old.categoryId,
        categoryName: old.categoryName,
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
        serialNumber: old.serialNumber,
        passportId: old.passportId,
        notes: old.notes,
        createdAt: old.createdAt,
      );
    }

    if (FirebaseBootstrap.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_collection)
            .doc(itemId)
            .update({'status': newStatus.name});
      } catch (e) {
        debugPrint('[W2V:EWasteService] updateStatus Firestore error: $e');
      }
    }
  }

  /// Delete an item
  Future<void> deleteItem(String itemId) async {
    _localCache.removeWhere((i) => i.id == itemId);
    if (FirebaseBootstrap.isInitialized) {
      try {
        await FirebaseFirestore.instance.collection(_collection).doc(itemId).delete();
      } catch (e) {
        debugPrint('[W2V:EWasteService] deleteItem error: $e');
      }
    }
  }
}
