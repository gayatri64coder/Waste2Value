import 'package:flutter/material.dart';
import '../../core/config/environment_config.dart';
import '../../core/config/firebase_bootstrap.dart';
import '../features/diagnostics/system_diagnostics_screen.dart';

/// A sleek top status indicator informing developers about active environment
/// and credentials readiness (Firebase & Google Maps).
class SystemStatusBanner extends StatelessWidget {
  const SystemStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isFirebaseReady = FirebaseBootstrap.isInitialized;
    final isMapsReady = EnvironmentConfig.isGoogleMapsConfigured;

    // In production with all credentials, hide the development banner
    if (EnvironmentConfig.isProduction && isFirebaseReady && isMapsReady) {
      return const SizedBox.shrink();
    }

    final hasPendingConfig = !isFirebaseReady || !isMapsReady;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: hasPendingConfig
            ? const Color(0xFFFEF3C7) // Warm amber warning
            : const Color(0xFFD1FAE5), // Mint success
        border: Border(
          bottom: BorderSide(
            color: hasPendingConfig
                ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                : const Color(0xFF10B981).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasPendingConfig
                ? Icons.info_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 18,
            color: hasPendingConfig
                ? const Color(0xFFB45309)
                : const Color(0xFF065F46),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasPendingConfig
                  ? '[${EnvironmentConfig.environment.name.toUpperCase()}] Config pending: '
                      '${!isFirebaseReady ? 'Firebase' : ''}'
                      '${!isFirebaseReady && !isMapsReady ? ' & ' : ''}'
                      '${!isMapsReady ? 'Google Maps' : ''} (Running in Offline Dev Mode)'
                  : '[${EnvironmentConfig.environment.name.toUpperCase()}] All Services Connected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasPendingConfig
                    ? const Color(0xFF92400E)
                    : const Color(0xFF065F46),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SystemDiagnosticsScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasPendingConfig
                    ? const Color(0xFFFDE68A)
                    : const Color(0xFFA7F3D0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Diagnostics',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: hasPendingConfig
                      ? const Color(0xFF78350F)
                      : const Color(0xFF047857),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
