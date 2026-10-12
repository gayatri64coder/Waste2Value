import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/recycling_certificate.dart';
import '../../theme/app_theme.dart';

class RecyclingCertificateScreen extends StatelessWidget {
  final RecyclingCertificate? certificate;

  const RecyclingCertificateScreen({super.key, this.certificate});

  @override
  Widget build(BuildContext context) {
    final user = AuthRepository().currentUser;
    final cert = certificate ??
        RecyclingCertificate(
          certificateNumber: 'W2V-2026-CERT-88492',
          userId: user?.id ?? 'demo_user_001',
          recipientName: user?.displayName ?? 'Maya Patel',
          deviceSummary: '1x MacBook Pro 13", 1x Galaxy S20, 1x PCB Board',
          totalWeightKg: 5.4,
          co2AvoidedKg: 38.6,
          toxicWasteDivertedGrams: 145.0,
          certifyingFacility: 'EcoCycler Certified R2 Hub - Whitefield',
          facilityR2License: 'SERI-R2v3-CERT-94021',
          issuedAt: DateTime.now().subtract(const Duration(days: 2)),
          verificationHash: 'SHA256:7f92a18b6c4e09f5832a89104b2c89f5',
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ESG Recycling Certificate'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Certificate Container
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Seal & Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.lightMint,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryGreen, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.verified,
                        color: AppTheme.primaryGreen, size: 36),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'CERTIFICATE OF SAFE DISPOSAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                Text(
                  'ELECTRONIC WASTE DIVERSION & ESG RECOVERY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Certificate ID: ${cert.certificateNumber}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slateDark,
                  ),
                ),
                const Divider(height: 32, thickness: 1),

                // Issued To
                const Text(
                  'THIS IS PROUDLY PRESENTED TO',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.0,
                    color: AppTheme.textMutedLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cert.recipientName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slateDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'In recognition of diverting electronic waste from municipal landfills '
                  'and ensuring compliant R2 circular material recovery for: "${cert.deviceSummary}".',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Environmental Metrics Grid
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Diverted Mass',
                          value: '${cert.totalWeightKg} kg',
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      Container(height: 30, width: 1, color: AppTheme.borderLight),
                      Expanded(
                        child: _buildMetricItem(
                          label: 'CO₂ Avoided',
                          value: '${cert.co2AvoidedKg} kg',
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                      Container(height: 30, width: 1, color: AppTheme.borderLight),
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Toxics Isolated',
                          value: '${cert.toxicWasteDivertedGrams.toStringAsFixed(0)} g',
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Issuer details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CERTIFYING RECYCLER:',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textMutedLight)),
                        Text(cert.certifyingFacility,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700)),
                        Text('License: ${cert.facilityR2License}',
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.textMutedLight)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('DATE ISSUED:',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textMutedLight)),
                        Text(
                          '${cert.issuedAt.day}/${cert.issuedAt.month}/${cert.issuedAt.year}',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    cert.verificationHash,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9,
                      fontFamily: 'monospace',
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Download / Share Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share Certificate'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Certificate link copied to clipboard.'),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Save PDF'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saved: ${cert.certificateNumber}.pdf'),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textMutedLight,
          ),
        ),
      ],
    );
  }
}
