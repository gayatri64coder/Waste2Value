import 'package:flutter/material.dart';
import '../../../core/config/environment_config.dart';
import '../../../core/config/firebase_bootstrap.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/user_profile.dart';
import '../../theme/app_theme.dart';

class SystemDiagnosticsScreen extends StatelessWidget {
  const SystemDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isFirebaseReady = FirebaseBootstrap.isInitialized;
    final isMapsReady = EnvironmentConfig.isGoogleMapsConfigured;
    final isExternalAiReady = EnvironmentConfig.isExternalAiConfigured;
    final authRepo = AuthRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('System & Security Diagnostics'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header summary
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
                  children: [
                    const Icon(Icons.security_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Configuration & Credentials Status',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Environment: ${EnvironmentConfig.environment.name.toUpperCase()}',
                            style: const TextStyle(
                              color: Color(0xFFA7F3D0),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'This screen monitors external credentials supplied by the project team. '
                  'The application is built to compile and run gracefully even when credentials are pending.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Security Policy Alert
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF1D4ED8), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'SECURITY RULE: API keys, Firebase credentials, and secrets are NEVER hardcoded or committed to GitHub. '
                    'All sensitive files are strictly excluded in .gitignore.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E40AF),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'EXTERNAL CREDENTIALS AUDIT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 12),

          // 1. Firebase Android
          _buildCredentialCard(
            context: context,
            title: '1. Firebase Android Configuration',
            status: isFirebaseReady ? 'Connected' : 'Pending Configuration',
            isReady: isFirebaseReady,
            requiredForMvp: 'Required for Cloud Sync (Offline Dev Fallback Active)',
            whereToObtain:
                'Firebase Console > Project Settings > General > Your Apps > Download google-services.json',
            whereToConfigure:
                'Copy google-services.json to android/app/google-services.json',
            details:
                'Provides Firebase Authentication, Cloud Firestore, Firebase Storage, and Cloud Messaging. '
                'When pending, the app automatically runs in local development mode.',
          ),
          const SizedBox(height: 14),

          // 2. Google Maps API Key
          _buildCredentialCard(
            context: context,
            title: '2. Google Maps API Key',
            status: isMapsReady ? 'Configured' : 'Placeholder Detected',
            isReady: isMapsReady,
            requiredForMvp: 'Required for Live Map Tiles (Interactive Radar Fallback Active)',
            whereToObtain:
                'Google Cloud Console > APIs & Services > Credentials > Create API Key (Enable Maps SDK for Android & Places API)',
            whereToConfigure:
                'Add MAPS_API_KEY=YOUR_KEY to local.properties or pass --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY',
            details:
                'Used for vector/satellite map rendering in Collection Points. '
                'When placeholder is detected, the app renders the interactive drop-off radar and center search.',
          ),
          const SizedBox(height: 14),

          // 3. Local AI Engine vs External AI
          _buildCredentialCard(
            context: context,
            title: '3. AI Engine & Assistant',
            status: isExternalAiReady
                ? 'External AI Key Configured'
                : 'Active (Zero-Cost Local Heuristic & FAQ)',
            isReady: true,
            requiredForMvp: 'MVP uses 100% Local AI (External AI is Optional)',
            whereToObtain:
                'Google AI Studio / Vertex AI (only if external LLM is desired in post-MVP)',
            whereToConfigure:
                'Set AI_API_KEY in .env or pass --dart-define=AI_API_KEY=YOUR_KEY',
            details:
                'MVP includes rule-based valuation, device diagnostic inspection checks, and the offline EcoBot FAQ assistant with zero API costs.',
          ),
          const SizedBox(height: 24),

          // Testing Role Switcher
          const Text(
            'DEVELOPMENT ROLE SWITCHER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Switch active user persona to preview role-based views:',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMutedLight),
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: authRepo,
                    builder: (context, _) {
                      final currentRole =
                          authRepo.currentUser?.role ?? UserRole.citizen;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: UserRole.values.map((role) {
                          final isSelected = currentRole == role;
                          return ChoiceChip(
                            label: Text(role.label),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) authRepo.switchDemoRole(role);
                            },
                            selectedColor: AppTheme.lightMint,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.primaryGreen
                                  : AppTheme.textLight,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialCard({
    required BuildContext context,
    required String title,
    required String status,
    required bool isReady,
    required String requiredForMvp,
    required String whereToObtain,
    required String whereToConfigure,
    required String details,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isReady
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isReady ? Icons.check_circle : Icons.pending_rounded,
                        size: 14,
                        color: isReady
                            ? const Color(0xFF065F46)
                            : const Color(0xFF92400E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isReady
                              ? const Color(0xFF065F46)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              details,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.35,
              ),
            ),
            const Divider(height: 20),
            _buildMetaRow(
              icon: Icons.flag_outlined,
              label: 'MVP Requirement:',
              value: requiredForMvp,
            ),
            const SizedBox(height: 8),
            _buildMetaRow(
              icon: Icons.link_rounded,
              label: 'Where to Obtain:',
              value: whereToObtain,
            ),
            const SizedBox(height: 8),
            _buildMetaRow(
              icon: Icons.folder_zip_outlined,
              label: 'Where to Configure:',
              value: whereToConfigure,
              isMonospace: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMonospace = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontFamily: isMonospace ? 'monospace' : null,
                    color: isMonospace
                        ? const Color(0xFF0F5132)
                        : const Color(0xFF475569),
                    fontWeight:
                        isMonospace ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
