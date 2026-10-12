import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/passport_service.dart';
import '../models/impact_metrics_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class ImpactDashboardScreen extends StatefulWidget {
  const ImpactDashboardScreen({super.key});

  @override
  State<ImpactDashboardScreen> createState() => _ImpactDashboardScreenState();
}

class _ImpactDashboardScreenState extends State<ImpactDashboardScreen> {
  ImpactMetrics? _metrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final userId = context.read<AuthProvider>().currentUser?.id ?? 'demo_user_001';
    final m = await PassportService.instance.fetchImpactMetrics(userId);
    if (mounted) setState(() { _metrics = m; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentMint))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 200,
                  backgroundColor: const Color(0xFF0F5132),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
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
                          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('My Environmental Impact',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Text(
                                'Your contribution to SDG 12, 13 & circular economy goals',
                                style: TextStyle(
                                    color: Colors.white.withAlpha(200),
                                    fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _TopStat(
                                      label: 'Items Recycled',
                                      value: '${_metrics?.itemsRecycled ?? 3}',
                                      icon: '♻️'),
                                  const SizedBox(width: 20),
                                  _TopStat(
                                      label: 'Global Rank',
                                      value: '#${_metrics?.globalRank ?? 2847}',
                                      icon: '🏆'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_metrics != null)
                  SliverToBoxAdapter(
                    child: _MetricsBody(metrics: _metrics!),
                  ),
              ],
            ),
    );
  }
}

class _MetricsBody extends StatelessWidget {
  final ImpactMetrics metrics;
  const _MetricsBody({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary impact cards
          Row(
            children: [
              Expanded(
                child: _ImpactCard(
                  label: 'CO₂ Avoided',
                  value: Formatters.formatWeight(metrics.co2SavedKg),
                  sub: '≈ ${(metrics.co2SavedKg / 21.7).toStringAsFixed(1)} trees/yr',
                  icon: '🌿',
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ImpactCard(
                  label: 'E-Waste Diverted',
                  value: Formatters.formatWeight(metrics.totalKgRecycled),
                  sub: 'from landfills',
                  icon: '🗑️',
                  color: AppColors.accentMint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ImpactCard(
                  label: 'Green Credits',
                  value: '${metrics.greenCreditsEarned}',
                  sub: 'total earned',
                  icon: '🌱',
                  color: AppColors.sdg8,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ImpactCard(
                  label: 'Precious Metals',
                  value: '${metrics.preciousMetalsRecoveredGrams.toStringAsFixed(1)} g',
                  sub: 'Au + Ag + Cu + Pd',
                  icon: '🥇',
                  color: AppColors.amberGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // SDG Contribution Section
          _SectionHeader('SDG Contribution Tracker'),
          const SizedBox(height: 12),
          _SdgCard(
            sdgNumber: 12,
            title: 'Responsible Consumption',
            description: 'Diverted ${Formatters.formatWeight(metrics.totalKgRecycled)} of e-waste from landfills this year.',
            color: AppColors.sdg12,
            progress: (metrics.totalKgRecycled / 50).clamp(0, 1),
            target: '50 kg/year goal',
          ),
          _SdgCard(
            sdgNumber: 13,
            title: 'Climate Action',
            description: '${Formatters.formatWeight(metrics.co2SavedKg)} CO₂ emissions avoided through responsible recycling.',
            color: AppColors.sdg13,
            progress: (metrics.co2SavedKg / 150).clamp(0, 1),
            target: '150 kg CO₂/year goal',
          ),
          _SdgCard(
            sdgNumber: 11,
            title: 'Sustainable Cities',
            description: 'Contributed to ${metrics.citiesImpacted} local clean technology initiatives.',
            color: AppColors.sdg11,
            progress: (metrics.citiesImpacted / 5).clamp(0, 1),
            target: '5 city impact goal',
          ),
          _SdgCard(
            sdgNumber: 8,
            title: 'Decent Work & Growth',
            description: 'Supported ${metrics.localJobsSupported} local e-waste collection jobs via circular economy.',
            color: AppColors.sdg8,
            progress: (metrics.localJobsSupported / 10).clamp(0, 1),
            target: '10 jobs supported goal',
          ),
          const SizedBox(height: 20),

          // Equivalence section
          _SectionHeader('Your Impact in Real Terms'),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _EquivalenceCard(
                  icon: '🌳',
                  value:
                      '${metrics.treesPlantedEquivalent}',
                  label: 'Trees Equivalent'),
              _EquivalenceCard(
                  icon: '💡',
                  value:
                      '${(metrics.co2SavedKg * 0.44).toStringAsFixed(0)} kWh',
                  label: 'Energy Saved'),
              _EquivalenceCard(
                  icon: '🚗',
                  value:
                      '${(metrics.co2SavedKg / 0.21).toStringAsFixed(0)} km',
                  label: 'Driving Avoided'),
              _EquivalenceCard(
                  icon: '💧',
                  value:
                      '${(metrics.totalKgRecycled * 140).toStringAsFixed(0)} L',
                  label: 'Water Saved'),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _TopStat extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _TopStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withAlpha(200), fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final String icon;
  final Color color;
  const _ImpactCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w600)),
          Text(sub,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _SdgCard extends StatelessWidget {
  final int sdgNumber;
  final String title;
  final String description;
  final Color color;
  final double progress;
  final String target;

  const _SdgCard({
    required this.sdgNumber,
    required this.title,
    required this.description,
    required this.color,
    required this.progress,
    required this.target,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('$sdgNumber',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SDG $sdgNumber',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color)),
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textDark)),
                  ],
                ),
              ),
              Text('${(progress * 100).toInt()}%',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: color, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withAlpha(25),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(description,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(target,
              style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EquivalenceCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  const _EquivalenceCard(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.primaryGreen)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark));
  }
}
