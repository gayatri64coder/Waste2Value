import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pickup_provider.dart';
import '../models/collection_point_model.dart';
import '../theme/app_colors.dart';

class CollectionPointsScreen extends StatefulWidget {
  const CollectionPointsScreen({super.key});

  @override
  State<CollectionPointsScreen> createState() => _CollectionPointsScreenState();
}

class _CollectionPointsScreenState extends State<CollectionPointsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PickupProvider>().loadCollectionPoints();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickup = context.watch<PickupProvider>();
    final filtered = pickup.centers
        .where((c) =>
            _query.isEmpty ||
            c.name.toLowerCase().contains(_query.toLowerCase()) ||
            c.city.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Collection Centers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by name or city…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        })
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // Map placeholder banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGreen.withAlpha(50)),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined,
                        color: AppColors.primaryGreen, size: 48),
                    SizedBox(height: 8),
                    Text('Interactive Map',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen)),
                    Text('Google Maps SDK — Add API Key in --dart-define',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text('${filtered.length} centers found',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted)),
                const Spacer(),
                const Icon(Icons.filter_list_rounded,
                    size: 16, color: AppColors.textMuted),
              ],
            ),
          ),

          // Center list
          Expanded(
            child: pickup.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.accentMint))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _CollectionCenterCard(center: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CollectionCenterCard extends StatelessWidget {
  final CollectionPoint center;
  const _CollectionCenterCard({required this.center});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('♻️', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(center.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(center.address,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        maxLines: 2),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (center.distanceKm != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentMint.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                          '${center.distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentMint)),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.amberGold),
                      Text(' ${center.rating}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.amberGold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Certifications
          Wrap(
            spacing: 6,
            children: [
              if (center.isCertifiedR2)
                _CertBadge(label: 'R2v3', color: AppColors.primaryGreen),
              if (center.isCertifiedEStewards)
                _CertBadge(label: 'e-Stewards', color: AppColors.accentMint),
              if (center.acceptsBatteries)
                _CertBadge(label: '🔋 Batteries', color: AppColors.amberGold),
              if (center.acceptsHazardous)
                _CertBadge(label: '⚠️ Hazardous', color: AppColors.alertRed),
            ],
          ),
          const SizedBox(height: 10),

          // Hours + actions
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Expanded(
                child: Text(center.operatingHours,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed('/pickup-dropoff'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text('Book Slot'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CertBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CertBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}
