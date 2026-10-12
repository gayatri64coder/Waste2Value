import 'package:flutter/material.dart';
import '../models/ewaste_item_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class ItemDetailsScreen extends StatelessWidget {
  final EWasteItem item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            expandedHeight: 160,
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
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                            maxLines: 2),
                        const SizedBox(height: 4),
                        Text(item.categoryName,
                            style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status banner
                  _StatusBanner(status: item.status),
                  const SizedBox(height: 16),

                  // Valuation cards
                  Row(
                    children: [
                      Expanded(
                          child: _MetricCard(
                              label: 'Estimated Value',
                              value:
                                  Formatters.formatCurrency(item.estimatedValue),
                              color: AppColors.amberGold,
                              icon: Icons.attach_money_rounded)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _MetricCard(
                              label: 'Green Credits',
                              value: '+${item.greenCreditsEarned}',
                              color: AppColors.accentMint,
                              icon: Icons.eco_rounded)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _MetricCard(
                              label: 'CO₂ Saved',
                              value:
                                  '${item.carbonSavedKg.toStringAsFixed(1)} kg',
                              color: AppColors.sdg13,
                              icon: Icons.air_rounded)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _MetricCard(
                              label: 'Weight',
                              value: Formatters.formatWeight(item.weightKg),
                              color: AppColors.cleanSkyBlue,
                              icon: Icons.scale_rounded)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Recommendation
                  _SectionCard(
                    title: 'Recommended Action',
                    child: Row(
                      children: [
                        const Icon(Icons.tips_and_updates_rounded,
                            color: AppColors.amberGold, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(item.recommendedAction,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Device Info
                  _SectionCard(
                    title: 'Device Information',
                    child: Column(
                      children: [
                        _InfoRow('Brand', item.brand),
                        _InfoRow('Model', item.model),
                        _InfoRow('Purchase Year', '${item.purchaseYear}'),
                        _InfoRow('Condition', item.condition.label),
                        _InfoRow('Functional Status', item.functionalStatus.label),
                        if (item.serialNumber != null)
                          _InfoRow('Serial / IMEI', item.serialNumber!),
                        _InfoRow('Submitted',
                            Formatters.formatDateTime(item.createdAt)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Precious Metals
                  _SectionCard(
                    title: '🔬 Precious Materials Estimate',
                    child: Column(
                      children: [
                        _MetalsRow(
                            '🥇 Gold', '${item.preciousMetals.goldGrams.toStringAsFixed(3)} g'),
                        _MetalsRow(
                            '🥈 Silver',
                            '${item.preciousMetals.silverGrams.toStringAsFixed(2)} g'),
                        _MetalsRow(
                            '🟤 Copper',
                            '${item.preciousMetals.copperGrams.toStringAsFixed(1)} g'),
                        _MetalsRow(
                            '⚪ Palladium',
                            '${item.preciousMetals.palladiumGrams.toStringAsFixed(4)} g'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Passport button
                  if (item.passportId != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.qr_code_rounded),
                        label: const Text('View Digital Product Passport'),
                        onPressed: () => Navigator.of(context)
                            .pushNamed('/ewaste-passport', arguments: item),
                      ),
                    ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.local_shipping_outlined),
                      label: const Text('Schedule Pickup'),
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/pickup-dropoff', arguments: item),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final EwasteStatus status;
  const _StatusBanner({required this.status});

  Color get _color => switch (status) {
        EwasteStatus.recycled => AppColors.accentMint,
        EwasteStatus.pickupScheduled => AppColors.cleanSkyBlue,
        EwasteStatus.inTransit => AppColors.amberGold,
        EwasteStatus.verified => AppColors.primaryGreen,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text('Status: ',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Text(status.label,
              style: TextStyle(fontWeight: FontWeight.w700, color: _color)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textDark)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted)),
                Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted)),
          Flexible(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _MetalsRow extends StatelessWidget {
  final String metal;
  final String value;
  const _MetalsRow(this.metal, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(metal, style: const TextStyle(fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.primaryGreen)),
        ],
      ),
    );
  }
}
