import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ewaste_provider.dart';
import '../providers/pickup_provider.dart';
import '../providers/notifications_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../models/ewaste_item_model.dart';
import '../models/pickup_request_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    if (userId.isEmpty) return;
    await Future.wait([
      context.read<EWasteProvider>().loadItemsForUser(userId),
      context.read<PickupProvider>().loadPickupsForUser(userId),
      context.read<NotificationsProvider>().loadForUser(userId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eWaste = context.watch<EWasteProvider>();
    final pickup = context.watch<PickupProvider>();
    final notifs = context.watch<NotificationsProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryGreen,
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ───
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.primaryGreen,
              expandedHeight: 180,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F5132), Color(0xFF059669)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hello, ${user?.displayName.split(' ').first ?? 'Eco Citizen'} 🌱',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.role.label ?? 'Eco Citizen',
                                      style: TextStyle(
                                          color: Colors.white.withAlpha(200),
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.notifications_outlined,
                                        color: Colors.white, size: 26),
                                    onPressed: () =>
                                        Navigator.of(context).pushNamed('/notifications'),
                                  ),
                                  if (notifs.unreadCount > 0)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: AppColors.alertRed,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${notifs.unreadCount}',
                                            style: const TextStyle(
                                                color: Colors.white, fontSize: 9),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Credits badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.eco_rounded,
                                    color: AppColors.lightMint, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  '${Formatters.formatCredits(user?.greenCredits ?? 0)} Green Credits',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
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
            ),

            // ─── Body ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    _SectionTitle(title: 'Quick Actions'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.add_circle_outline_rounded,
                            label: 'Submit\nE-Waste',
                            color: AppColors.primaryGreen,
                            onTap: () => Navigator.of(context).pushNamed('/submit-ewaste'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.local_shipping_outlined,
                            label: 'Schedule\nPickup',
                            color: AppColors.accentMint,
                            onTap: () =>
                                Navigator.of(context).pushNamed('/pickup-dropoff'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.location_on_outlined,
                            label: 'Find\nCenters',
                            color: AppColors.cleanSkyBlue,
                            onTap: () =>
                                Navigator.of(context).pushNamed('/collection-points'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.bar_chart_rounded,
                            label: 'My\nImpact',
                            color: AppColors.sdg13,
                            onTap: () =>
                                Navigator.of(context).pushNamed('/impact-dashboard'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Active Pickups
                    if (pickup.activePickups.isNotEmpty) ...[
                      _SectionTitle(
                        title: 'Active Pickups',
                        action: 'View All',
                        onAction: () =>
                            Navigator.of(context).pushNamed('/tracking'),
                      ),
                      const SizedBox(height: 12),
                      ...pickup.activePickups.take(2).map(
                            (p) => _PickupStatusCard(pickup: p),
                          ),
                      const SizedBox(height: 24),
                    ],

                    // My E-Waste Items
                    _SectionTitle(
                      title: 'My E-Waste Items',
                      action: 'Submit New',
                      onAction: () =>
                          Navigator.of(context).pushNamed('/submit-ewaste'),
                    ),
                    const SizedBox(height: 12),
                    if (eWaste.isLoading)
                      const _LoadingCard()
                    else if (eWaste.items.isEmpty)
                      _EmptyState(
                        icon: '📱',
                        title: 'No items submitted yet',
                        subtitle: 'Submit your first e-waste item\nto start earning green credits.',
                        buttonLabel: 'Submit E-Waste',
                        onTap: () => Navigator.of(context).pushNamed('/submit-ewaste'),
                      )
                    else
                      ...eWaste.items.take(3).map(
                            (item) => _EWasteItemCard(
                              item: item,
                              onTap: () => Navigator.of(context).pushNamed(
                                '/item-details',
                                arguments: item,
                              ),
                            ),
                          ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionTitle({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentMint)),
          ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                    height: 1.3)),
          ],
        ),
      ),
    );
  }
}

class _PickupStatusCard extends StatelessWidget {
  final PickupRequest pickup;

  const _PickupStatusCard({required this.pickup});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accentMint.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🚚', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pickup.itemsSummary,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(pickup.status.label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.accentMint,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(
            Formatters.formatDate(pickup.preferredDate),
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _EWasteItemCard extends StatelessWidget {
  final EWasteItem item;
  final VoidCallback onTap;

  const _EWasteItemCard({required this.item, required this.onTap});

  Color get _statusColor {
    return switch (item.status) {
      EwasteStatus.recycled => AppColors.accentMint,
      EwasteStatus.pickupScheduled => AppColors.cleanSkyBlue,
      EwasteStatus.inTransit => AppColors.amberGold,
      _ => AppColors.textMuted,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.devices_rounded,
                    color: AppColors.primaryGreen, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(item.categoryName,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(item.status.label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _statusColor)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Formatters.formatCurrency(item.estimatedValue),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.primaryGreen)),
                const SizedBox(height: 3),
                Text('+${item.greenCreditsEarned} pts',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.accentMint,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.accentMint,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onTap, child: Text(buttonLabel)),
        ],
      ),
    );
  }
}
