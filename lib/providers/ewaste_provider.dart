import 'package:flutter/foundation.dart';
import '../services/ewaste_service.dart';
import '../models/ewaste_item_model.dart';

/// Provider for e-waste item list state management
class EWasteProvider extends ChangeNotifier {
  final EWasteService _service;
  List<EWasteItem> _items = [];
  bool _isLoading = false;
  String? _error;

  EWasteProvider({EWasteService? service})
      : _service = service ?? EWasteService.instance;

  List<EWasteItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<EWasteItem> get activeItems =>
      _items.where((i) => i.status != EwasteStatus.recycled).toList();

  List<EWasteItem> get recycledItems =>
      _items.where((i) => i.status == EwasteStatus.recycled).toList();

  Future<void> loadItemsForUser(String userId) async {
    _setLoading(true);
    _error = null;
    try {
      _items = await _service.fetchItemsForUser(userId);
    } catch (e) {
      _error = 'Failed to load items. $e';
      debugPrint('[W2V:EWasteProvider] loadItems error: $e');
    }
    _setLoading(false);
  }

  Future<EWasteItem?> addItem(EWasteItem item) async {
    _error = null;
    try {
      final saved = await _service.addItem(item);
      _items.insert(0, saved);
      notifyListeners();
      return saved;
    } catch (e) {
      _error = 'Failed to submit item. $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> updateStatus(String itemId, EwasteStatus status) async {
    await _service.updateStatus(itemId, status);
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      final old = _items[idx];
      _items[idx] = EWasteItem(
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
        status: status,
        recommendedAction: old.recommendedAction,
        serialNumber: old.serialNumber,
        passportId: old.passportId,
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
