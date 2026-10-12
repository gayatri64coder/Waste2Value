import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/passport_service.dart';
import '../models/ewaste_item_model.dart';
import '../models/ewaste_passport_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class EWastePassportScreen extends StatefulWidget {
  final EWasteItem item;
  const EWastePassportScreen({super.key, required this.item});

  @override
  State<EWastePassportScreen> createState() => _EWastePassportScreenState();
}

class _EWastePassportScreenState extends State<EWastePassportScreen> {
  EWastePassport? _passport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPassport();
  }

  Future<void> _loadPassport() async {
    final p = await PassportService.instance.fetchPassportForItem(widget.item.id);
    if (mounted) setState(() { _passport = p; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Digital Product Passport'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_passport != null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {
                Clipboard.setData(ClipboardData(
                    text: 'W2V Passport: ${_passport!.passportId}\n'
                        'Device: ${_passport!.deviceTitle}\n'
                        'CO₂ Saved: ${_passport!.carbonFootprintKg} kg\n'
                        'Verify: https://waste2value.org/passport/${_passport!.passportId}'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passport link copied!')),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentMint))
          : _passport == null
              ? _PassportUnavailable(item: widget.item)
              : _PassportView(passport: _passport!),
    );
  }
}

class _PassportView extends StatelessWidget {
  final EWastePassport passport;
  const _PassportView({required this.passport});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // QR Passport Card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F5132), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withAlpha(60),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('♻️', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Digital Product Passport',
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                  letterSpacing: 1.2)),
                          Text(passport.passportId,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('VERIFIED',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_2_rounded,
                            size: 80, color: AppColors.primaryGreen),
                        Text('Scan to Verify',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(passport.deviceTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text('${passport.brand} ${passport.model} • ${passport.manufacturingYear}',
                    style: TextStyle(
                        color: Colors.white.withAlpha(200), fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PassportStat(
                        label: 'CO₂ Saved',
                        value: '${passport.carbonFootprintKg} kg',
                        icon: '🌍'),
                    _PassportStat(
                        label: 'Circularity',
                        value: '${passport.circularityRatePercent}%',
                        icon: '♻️'),
                    _PassportStat(
                        label: 'Repairability',
                        value: '${passport.repairabilityScore}/10',
                        icon: '🔧'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Material Composition
          _PassportSection(
            title: '🧪 Material Composition',
            child: Column(
              children: [
                _CompositionBar(
                    label: 'Copper & Alloys',
                    percent: passport.composition.copperAndAlloysPercent,
                    color: AppColors.amberGold),
                _CompositionBar(
                    label: 'Ferrous Metals',
                    percent: passport.composition.ferrousMetalsPercent,
                    color: AppColors.cleanSkyBlue),
                _CompositionBar(
                    label: 'Plastics',
                    percent: passport.composition.plasticsPercent,
                    color: const Color(0xFF9333EA)),
                _CompositionBar(
                    label: 'Glass & Ceramics',
                    percent: passport.composition.glassAndCeramicsPercent,
                    color: AppColors.textMuted),
                _CompositionBar(
                    label: 'Precious Metals',
                    percent: passport.composition.preciousMetalsPercent,
                    color: AppColors.primaryGreen),
                _CompositionBar(
                    label: 'Battery Cells',
                    percent: passport.composition.batteryCellsPercent,
                    color: AppColors.alertRed),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Hazardous Substances
          if (passport.hazardousSubstancesFlagged.isNotEmpty)
            _PassportSection(
              title: '⚠️ Hazardous Substance Flags',
              child: Column(
                children: passport.hazardousSubstancesFlagged
                    .map((s) => _HazardRow(substance: s))
                    .toList(),
              ),
            ),
          const SizedBox(height: 12),

          // Chain of Custody
          _PassportSection(
            title: '🔗 Chain of Custody',
            child: Column(
              children: [
                _DetailRow('Certifying Facility', passport.certifyingFacility),
                _DetailRow('License Number', passport.licenseNumber),
                _DetailRow('Issued', Formatters.formatDateTime(passport.issuedAt)),
                _DetailRow(
                    'Hash',
                    passport.chainOfCustodyHash.substring(0, 28) + '...',
                    mono: true),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PassportStat extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _PassportStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withAlpha(180), fontSize: 10)),
      ],
    );
  }
}

class _PassportSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _PassportSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CompositionBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  const _CompositionBar(
      {required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textDark)),
              Text('${percent.toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: color.withAlpha(25),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _HazardRow extends StatelessWidget {
  final String substance;
  const _HazardRow({required this.substance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.alertRed, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(substance,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  const _DetailRow(this.label, this.value, {this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    fontFamily: mono ? 'monospace' : null)),
          ),
        ],
      ),
    );
  }
}

class _PassportUnavailable extends StatelessWidget {
  final EWasteItem item;
  const _PassportUnavailable({required this.item});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📋', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Passport Not Yet Issued',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(
                'The Digital Product Passport for ${item.brand} ${item.model} '
                'will be issued after the item is processed and verified '
                'at a certified facility.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('Schedule Pickup Now'),
              onPressed: () =>
                  Navigator.of(context).pushNamed('/pickup-dropoff'),
            ),
          ],
        ),
      ),
    );
  }
}
