import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/ewaste_repository.dart';
import '../../../data/repositories/pickup_repository.dart';
import '../../../domain/models/ewaste_item.dart';
import '../../../domain/models/pickup_request.dart';
import '../../theme/app_theme.dart';
import '../../widgets/system_status_banner.dart';
import '../pickups/pickup_tracking_screen.dart';
import '../certificate/recycling_certificate_screen.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToValuation;
  final VoidCallback onNavigateToCenters;
  final VoidCallback onNavigateToPickups;
  final VoidCallback onNavigateToChat;

  const DashboardScreen({
    super.key,
    required this.onNavigateToValuation,
    required this.onNavigateToCenters,
    required this.onNavigateToPickups,
    required this.onNavigateToChat,
  });

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    final ewasteRepo = EwasteRepository();
    final pickupRepo = PickupRepository();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SystemStatusBanner(),
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([authRepo, ewasteRepo, pickupRepo]),
                builder: (context, _) {
                  final user = authRepo.currentUser;
                  final pickups = pickupRepo.pickups;
                  final items = ewasteRepo.items;

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    children: [
                      // Header with greeting and profile
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.primaryGreen,
                                  AppTheme.accentMint
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '🌱',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${user?.displayName ?? 'Eco Citizen'}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.lightMint,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        user?.role.label ?? 'Citizen',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryGreen,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tier: Circular Guardian',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline_rounded),
                            tooltip: 'EcoBot AI Assistant',
                            onPressed: onNavigateToChat,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Environmental Impact Scoreboard
                      _buildImpactCard(user),
                      const SizedBox(height: 20),

                      // Quick Action Grid
                      const Text(
                        'QUICK ACTIONS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppTheme.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.25,
                        children: [
                          _buildActionTile(
                            icon: Icons.calculate_outlined,
                            iconColor: const Color(0xFF0F5132),
                            bgColor: const Color(0xFFE8F5E9),
                            title: 'Valuate Device',
                            subtitle: 'Rule-based price & metals estimate',
                            onTap: onNavigateToValuation,
                          ),
                          _buildActionTile(
                            icon: Icons.map_outlined,
                            iconColor: const Color(0xFF0284C7),
                            bgColor: const Color(0xFFE0F2FE),
                            title: 'Drop-off Centers',
                            subtitle: 'Find verified R2 e-waste hubs',
                            onTap: onNavigateToCenters,
                          ),
                          _buildActionTile(
                            icon: Icons.local_shipping_outlined,
                            iconColor: const Color(0xFFD97706),
                            bgColor: const Color(0xFFFEF3C7),
                            title: 'Doorstep Pickup',
                            subtitle: 'Schedule free home collection',
                            onTap: onNavigateToPickups,
                          ),
                          _buildActionTile(
                            icon: Icons.smart_toy_outlined,
                            iconColor: const Color(0xFF7C3AED),
                            bgColor: const Color(0xFFF3E8FF),
                            title: 'Ask EcoBot',
                            subtitle: 'Offline guidance on data & safety',
                            onTap: onNavigateToChat,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Active Doorstep Pickup Tracking Card
                      if (pickups.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ACTIVE COLLECTION',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppTheme.textMutedLight,
                              ),
                            ),
                            TextButton(
                              onPressed: onNavigateToPickups,
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        _buildPickupTrackingCard(context, pickups.first),
                        const SizedBox(height: 20),
                      ],

                      // ESG Certificate Promo Banner
                      _buildCertificateBanner(context),
                      const SizedBox(height: 20),

                      // Recent Listings Header & List
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'YOUR E-WASTE ASSETS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppTheme.textMutedLight,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('New Asset'),
                            onPressed: onNavigateToValuation,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: const Center(
                            child: Text(
                              'No devices evaluated yet.\nTap "Valuate Device" to calculate residual value!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppTheme.textMutedLight, fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ...items.map((item) => _buildItemTile(context, item)),

                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F5132), Color(0xFF15803D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F5132).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CIRCULAR IMPACT SCORE',
                style: TextStyle(
                  color: Color(0xFFA7F3D0),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.eco, color: Color(0xFFFDE68A), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${user?.greenCredits ?? 380} Credits',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCol(
                  value: '${user?.totalKgRecycled ?? 28.4} kg',
                  label: 'E-Waste Diverted',
                  icon: Icons.recycling_rounded,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildMetricCol(
                  value: '${user?.co2SavedKg ?? 86.5} kg',
                  label: 'CO₂ Emitted Prevented',
                  icon: Icons.cloud_outlined,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildMetricCol(
                  value: '${user?.treesPlantedEquivalent ?? 4}',
                  label: 'Trees Equivalent',
                  icon: Icons.forest_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFA7F3D0), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFD1FAE5),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMutedLight,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupTrackingCard(BuildContext context, PickupRequest pickup) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🚚', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pickup.itemsSummary,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Assigned: ${pickup.collectorName ?? 'Eco Dispatch'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pickup.status.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Slot: ${pickup.preferredTimeSlot}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PickupTrackingScreen(pickup: pickup),
                      ),
                    );
                  },
                  child: const Text(
                    'Track Details →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined,
              color: AppTheme.primaryGreen, size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESG Recycling Certificate',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF14532D),
                  ),
                ),
                Text(
                  'Download verified proof of green electronic waste disposal.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RecyclingCertificateScreen(),
                ),
              );
            },
            child: const Text('View Cert'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, EwasteItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(item.category.icon,
                style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Valuation: \$${item.estimatedValue.toStringAsFixed(0)} • ${item.status.label}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textMutedLight),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.lightMint,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '+${item.greenCreditsEarned} pts',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
      ),
    );
  }
}
