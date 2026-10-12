import 'package:flutter/foundation.dart';
import '../services/rewards_service.dart';
import '../models/reward_model.dart';
import '../models/reward_transaction_model.dart';

/// Provider for rewards catalogue and green credit balance state
class RewardsProvider extends ChangeNotifier {
  final RewardsService _service;
  List<Reward> _rewards = [];
  List<RewardTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  RewardsProvider({RewardsService? service})
      : _service = service ?? RewardsService.instance;

  List<Reward> get rewards => List.unmodifiable(_rewards);
  List<RewardTransaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalCredits => _service.calculateTotalCredits(_transactions);

  Future<void> loadRewards() async {
    _setLoading(true);
    try {
      _rewards = await _service.fetchRewardsCatalogue();
    } catch (e) {
      _error = 'Could not load rewards. $e';
    }
    _setLoading(false);
  }

  Future<void> loadTransactionsForUser(String userId) async {
    _setLoading(true);
    try {
      _transactions = await _service.fetchTransactionsForUser(userId);
    } catch (e) {
      _error = 'Could not load transactions. $e';
    }
    _setLoading(false);
  }

  Future<bool> redeemReward({
    required String userId,
    required Reward reward,
  }) async {
    if (totalCredits < reward.pointsCost) return false;
    _error = null;
    try {
      final txn = await _service.redeemReward(userId: userId, reward: reward);
      _transactions.insert(0, txn);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Redemption failed. $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> earnPoints({
    required String userId,
    required String activityTitle,
    required int points,
  }) async {
    try {
      final txn = await _service.earnPoints(
        userId: userId,
        activityTitle: activityTitle,
        points: points,
      );
      _transactions.insert(0, txn);
      notifyListeners();
    } catch (e) {
      debugPrint('[W2V:RewardsProvider] earnPoints error: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
