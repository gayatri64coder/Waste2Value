import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/pickup_provider.dart';
import '../models/pickup_request_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id ?? '';
      context.read<PickupProvider>().loadPickupsForUser(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pickup = context.watch<PickupProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pickup Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final uid = context.read<AuthProvider>().currentUser?.id ?? '';
          await context.read<PickupProvider>().loadPickupsForUser(uid);
        },
        color: AppColors.primaryGreen,
        child: pickup.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accentMint))
            : pickup.pickups.isEmpty
                ? _EmptyTracking()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: pickup.pickups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) =>
                        _PickupTrackingCard(pickup: pickup.pickups[i]),
                  ),
      ),
    );
  }
}

class _PickupTrackingCard extends StatelessWidget {
  final PickupRequest pickup;
  const _PickupTrackingCard({required this.pickup});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF0F5132), Color(0xFF059669)]),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(pickup.itemsSummary,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                _StatusChip(status: pickup.status),
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date + time
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      '${Formatters.formatDate(pickup.preferredDate)} • ${pickup.preferredTimeSlot}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(pickup.pickupAddress,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                if (pickup.collectorName != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightMint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.accentMint,
                          child: Text('R', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Assigned Collector',
                                  style: const TextStyle(
                                      fontSize: 10, color: AppColors.textMuted)),
                              Text(pickup.collectorName!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppColors.primaryGreen)),
                            ],
                          ),
                        ),
                        const Icon(Icons.phone_outlined,
                            color: AppColors.primaryGreen, size: 20),
                      ],
                    ),
                  ),
                ],

                // Timeline
                const SizedBox(height: 16),
                _TrackingTimeline(status: pickup.status),

                // Credits earned
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Est. Credits: +${pickup.estimatedGreenCredits} pts',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentMint)),
                    Text('Est. Weight: ${pickup.estimatedWeightKg} kg',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  final PickupStatus status;
  const _TrackingTimeline({required this.status});

  static const List<_TimelineStep> _steps = [
    _TimelineStep(
        label: 'Requested',
        icon: Icons.send_rounded,
        status: PickupStatus.requested),
    _TimelineStep(
        label: 'Assigned',
        icon: Icons.person_pin_circle_outlined,
        status: PickupStatus.assigned),
    _TimelineStep(
        label: 'In Transit',
        icon: Icons.local_shipping_outlined,
        status: PickupStatus.collectorEnRoute),
    _TimelineStep(
        label: 'Collected',
        icon: Icons.where_to_vote_outlined,
        status: PickupStatus.collected),
    _TimelineStep(
        label: 'Completed',
        icon: Icons.check_circle_outline_rounded,
        status: PickupStatus.completed),
  ];

  int _currentIndex() {
    return _steps.indexWhere((s) => s.status == status).clamp(0, _steps.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final currentIdx = _currentIndex();
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIdx = i ~/ 2;
          final isDone = stepIdx < currentIdx;
          return Expanded(
            child: Container(
              height: 2,
              color: isDone ? AppColors.accentMint : AppColors.borderLight,
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final isDone = stepIdx <= currentIdx;
        final step = _steps[stepIdx];
        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.accentMint
                    : AppColors.borderLight,
                shape: BoxShape.circle,
              ),
              child: Icon(step.icon,
                  color: isDone ? Colors.white : AppColors.textMuted,
                  size: 15),
            ),
            const SizedBox(height: 4),
            Text(step.label,
                style: TextStyle(
                    fontSize: 9,
                    color: isDone ? AppColors.primaryGreen : AppColors.textMuted,
                    fontWeight:
                        isDone ? FontWeight.w700 : FontWeight.w400)),
          ],
        );
      }),
    );
  }
}

class _TimelineStep {
  final String label;
  final IconData icon;
  final PickupStatus status;
  const _TimelineStep(
      {required this.label, required this.icon, required this.status});
}

class _StatusChip extends StatelessWidget {
  final PickupStatus status;
  const _StatusChip({required this.status});

  Color get _color => switch (status) {
        PickupStatus.completed => AppColors.accentMint,
        PickupStatus.assigned => AppColors.cleanSkyBlue,
        PickupStatus.collectorEnRoute => AppColors.amberGold,
        PickupStatus.cancelled => AppColors.alertRed,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withAlpha(80)),
      ),
      child: Text(status.label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: _color)),
    );
  }
}

class _EmptyTracking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚚', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('No Active Pickups',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('Schedule a pickup to track your items here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/pickup-dropoff'),
              child: const Text('Schedule Pickup'),
            ),
          ],
        ),
      ),
    );
  }
}
