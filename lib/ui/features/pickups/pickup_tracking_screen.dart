import 'package:flutter/material.dart';
import '../../../domain/models/pickup_request.dart';
import '../../theme/app_theme.dart';
import '../certificate/recycling_certificate_screen.dart';

class PickupTrackingScreen extends StatelessWidget {
  final PickupRequest pickup;

  const PickupTrackingScreen({super.key, required this.pickup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Collection Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Order ID & Status Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F5132), Color(0xFF065F46)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Request #${pickup.id.toUpperCase()}',
                      style: const TextStyle(
                        color: Color(0xFFA7F3D0),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pickup.status.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  pickup.itemsSummary,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Destination: ${pickup.centerName}',
                  style: const TextStyle(
                    color: Color(0xFFD1FAE5),
                    fontSize: 12,
                  ),
                ),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Slot: ${pickup.preferredTimeSlot}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      '+${pickup.estimatedGreenCredits} Green Credits',
                      style: const TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // QR Code Verification Pass
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'AGENT HANDOVER QR PASS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppTheme.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderLight, width: 2),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_2_rounded,
                              size: 100, color: AppTheme.slateDark),
                          Text(
                            pickup.id.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Show this QR code to the collection agent during doorstep handover.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Collector Profile Card
          if (pickup.collectorName != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.badge_outlined,
                            color: Color(0xFFB45309)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pickup.collectorName!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Contact: ${pickup.collectorPhone ?? "+91 98111 22334"}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone_in_talk,
                          color: AppTheme.primaryGreen),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Dialing agent: ${pickup.collectorPhone ?? "+91 98111 22334"}'),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Lifecycle Tracking Timeline
          const Text(
            'CHAIN OF CUSTODY TIMELINE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTimelineStep(
                    title: 'Pickup Requested',
                    desc: 'Item details and preferred time window submitted.',
                    isDone: true,
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    title: 'Collector Assigned',
                    desc: pickup.collectorName != null
                        ? '${pickup.collectorName} scheduled for collection route.'
                        : 'Dispatching nearest verified agent.',
                    isDone: pickup.status != PickupStatus.requested,
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    title: 'Doorstep Handover & Seal',
                    desc:
                        'Agent verifies device IMEI/Serial and places in antistatic tote.',
                    isDone: pickup.status == PickupStatus.collected ||
                        pickup.status == PickupStatus.inspected ||
                        pickup.status == PickupStatus.completed,
                    isLast: false,
                  ),
                  _buildTimelineStep(
                    title: 'Hub Inspection & ESG Credit Issued',
                    desc:
                        'Precision scale weighing at R2 hub and cryptographic certificate generation.',
                    isDone: pickup.status == PickupStatus.completed,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            icon: const Icon(Icons.verified_outlined),
            label: const Text('View Sample ESG Disposal Certificate'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RecyclingCertificateScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String desc,
    required bool isDone,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppTheme.primaryGreen : const Color(0xFFE2E8F0),
              ),
              child: Center(
                child: Icon(
                  isDone ? Icons.check : Icons.circle,
                  color: isDone ? Colors.white : const Color(0xFF94A3B8),
                  size: isDone ? 14 : 8,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: isDone ? AppTheme.primaryGreen : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDone ? AppTheme.textLight : AppTheme.textMutedLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.textMutedLight,
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
