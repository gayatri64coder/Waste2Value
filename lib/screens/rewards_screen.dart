import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/rewards_provider.dart';
import '../models/reward_model.dart';
import '../models/reward_transaction_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    await Future.wait([
      context.read<RewardsProvider>().loadRewards(),
      context.read<RewardsProvider>().loadTransactionsForUser(userId),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rewards = context.watch<RewardsProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: AppColors.primaryGreen,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F5132), Color(0xFF059669)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Green Rewards',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Text('🌱',
                                  style: TextStyle(fontSize: 32)),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Formatters.formatCredits(
                                        user?.greenCredits ?? rewards.totalCredits),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  const Text('Green Credits Available',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'Rewards Catalogue'),
                Tab(text: 'My Transactions'),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _RewardsCatalogue(
                  rewards: rewards.rewards,
                  isLoading: rewards.isLoading,
                  totalCredits: rewards.totalCredits,
                ),
                _TransactionHistory(transactions: rewards.transactions),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Catalogue Tab ──

class _RewardsCatalogue extends StatelessWidget {
  final List<Reward> rewards;
  final bool isLoading;
  final int totalCredits;

  const _RewardsCatalogue({
    required this.rewards,
    required this.isLoading,
    required this.totalCredits,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.accentMint));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rewards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _RewardCard(
        reward: rewards[i],
        canAfford: totalCredits >= rewards[i].pointsCost,
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Reward reward;
  final bool canAfford;

  const _RewardCard({required this.reward, required this.canAfford});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reward header
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: _categoryColor(reward.category).withAlpha(20),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Text(reward.icon,
                  style: const TextStyle(fontSize: 40)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(reward.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textDark)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? AppColors.primaryGreen.withAlpha(20)
                            : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${reward.pointsCost} pts',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: canAfford
                                  ? AppColors.primaryGreen
                                  : AppColors.textMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(reward.description,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: canAfford
                            ? () => _showRedeemDialog(context, reward)
                            : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: canAfford
                                  ? AppColors.primaryGreen
                                  : AppColors.borderLight),
                          foregroundColor: canAfford
                              ? AppColors.primaryGreen
                              : AppColors.textMuted,
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(canAfford
                            ? 'Redeem Now'
                            : 'Insufficient Credits'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(RewardCategory cat) {
    return switch (cat) {
      RewardCategory.electronics => AppColors.cleanSkyBlue,
      RewardCategory.voucher => AppColors.amberGold,
      RewardCategory.donation => AppColors.sdg13,
      RewardCategory.experience => AppColors.sdg12,
      _ => AppColors.primaryGreen,
    };
  }

  void _showRedeemDialog(BuildContext context, Reward reward) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Redeem: ${reward.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will cost ${reward.pointsCost} Green Credits.'),
            const SizedBox(height: 8),
            Text(reward.description,
                style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final userId = context.read<AuthProvider>().currentUser?.id ?? '';
              final success = await context.read<RewardsProvider>().redeemReward(
                    userId: userId,
                    reward: reward,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? '🎉 Redeemed! Code: ${reward.voucherCode ?? "Check email"}'
                      : '❌ Insufficient credits'),
                  backgroundColor:
                      success ? AppColors.primaryGreen : AppColors.alertRed,
                ));
              }
            },
            child: const Text('Confirm Redeem'),
          ),
        ],
      ),
    );
  }
}

// ── Transactions Tab ──

class _TransactionHistory extends StatelessWidget {
  final List<RewardTransaction> transactions;
  const _TransactionHistory({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No transactions yet.',
            style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const Divider(color: AppColors.borderLight),
      itemBuilder: (_, i) => _TransactionRow(transaction: transactions[i]),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final RewardTransaction transaction;
  const _TransactionRow({required this.transaction});

  bool get _isEarn => transaction.transactionType == 'earn';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isEarn
                  ? AppColors.accentMint.withAlpha(25)
                  : AppColors.alertRed.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isEarn
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              color: _isEarn ? AppColors.accentMint : AppColors.alertRed,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(Formatters.formatDateTime(transaction.timestamp),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
                if (transaction.voucherCode != null)
                  Text('Code: ${transaction.voucherCode}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(
            '${_isEarn ? '+' : ''}${transaction.pointsChange} pts',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: _isEarn ? AppColors.accentMint : AppColors.alertRed),
          ),
        ],
      ),
    );
  }
}
