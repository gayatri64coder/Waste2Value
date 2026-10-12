import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_bootstrap.dart';
import '../../models/reward_model.dart';
import '../../models/reward_transaction_model.dart';

/// Service for managing green credits, rewards catalogue, and transactions
class RewardsService {
  RewardsService._();
  static final RewardsService instance = RewardsService._();

  static const String _transactionsCollection = 'reward_transactions';
  static const String _rewardsCollection = 'rewards';

  final List<RewardTransaction> _localTransactions = _buildDefaultTransactions();

  static List<RewardTransaction> _buildDefaultTransactions() {
    return [
      RewardTransaction(
        id: 'txn_001',
        userId: 'demo_user_001',
        rewardId: 'ewaste_submission',
        title: 'MacBook Pro 13" Submitted',
        pointsChange: 180,
        transactionType: 'earn',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RewardTransaction(
        id: 'txn_002',
        userId: 'demo_user_001',
        rewardId: 'rew_001',
        title: '\$25 Off Refurbished Laptops Redeemed',
        pointsChange: -150,
        transactionType: 'redeem',
        voucherCode: 'CIRCULAR-LAPTOP-25',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
      ),
      RewardTransaction(
        id: 'txn_003',
        userId: 'demo_user_001',
        rewardId: 'ewaste_submission',
        title: 'Samsung Galaxy S20 Submitted',
        pointsChange: 85,
        transactionType: 'earn',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  /// Fetch rewards catalogue
  Future<List<Reward>> fetchRewardsCatalogue() async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        final query =
            await FirebaseFirestore.instance.collection(_rewardsCollection).get();
        if (query.docs.isNotEmpty) {
          return query.docs
              .map((doc) => Reward.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('[W2V:RewardsService] fetchRewards error: $e');
      }
    }
    return List.from(Reward.defaultRewards);
  }

  /// Fetch transaction history for user
  Future<List<RewardTransaction>> fetchTransactionsForUser(String userId) async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection(_transactionsCollection)
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .get();
        return query.docs
            .map((doc) => RewardTransaction.fromMap(doc.data(), doc.id))
            .toList();
      } catch (e) {
        debugPrint('[W2V:RewardsService] fetchTransactions error: $e');
      }
    }
    return _localTransactions.where((t) => t.userId == userId).toList();
  }

  /// Earn points for recycling activity
  Future<RewardTransaction> earnPoints({
    required String userId,
    required String activityTitle,
    required int points,
  }) async {
    final txn = RewardTransaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      rewardId: 'activity_earn',
      title: activityTitle,
      pointsChange: points,
      transactionType: 'earn',
      timestamp: DateTime.now(),
    );

    if (FirebaseBootstrap.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_transactionsCollection)
            .add(txn.toMap());
      } catch (e) {
        debugPrint('[W2V:RewardsService] earnPoints Firestore error: $e');
      }
    }
    _localTransactions.insert(0, txn);
    return txn;
  }

  /// Redeem a reward with points
  Future<RewardTransaction> redeemReward({
    required String userId,
    required Reward reward,
  }) async {
    final txn = RewardTransaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      rewardId: reward.id,
      title: '${reward.title} Redeemed',
      pointsChange: -reward.pointsCost,
      transactionType: 'redeem',
      voucherCode: reward.voucherCode,
      timestamp: DateTime.now(),
    );

    if (FirebaseBootstrap.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_transactionsCollection)
            .add(txn.toMap());
      } catch (e) {
        debugPrint('[W2V:RewardsService] redeemReward Firestore error: $e');
      }
    }
    _localTransactions.insert(0, txn);
    return txn;
  }

  /// Calculate total green credits from transactions
  int calculateTotalCredits(List<RewardTransaction> transactions) {
    return transactions.fold(0, (sum, txn) => sum + txn.pointsChange);
  }
}
