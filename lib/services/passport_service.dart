import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_bootstrap.dart';
import '../../models/ewaste_passport_model.dart';
import '../../models/impact_metrics_model.dart';

/// Service for E-Waste Passports and Impact Metrics
class PassportService {
  PassportService._();
  static final PassportService instance = PassportService._();

  static const String _passportsCollection = 'ewaste_passports';
  static const String _impactCollection = 'impact_metrics';

  final Map<String, EWastePassport> _localPassports = {};
  final Map<String, ImpactMetrics> _localMetrics = {};

  // ──────────────────── E-Waste Passport ────────────────────

  Future<EWastePassport?> fetchPassportForItem(String itemId) async {
    if (_localPassports.containsKey(itemId)) return _localPassports[itemId];

    if (FirebaseBootstrap.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection(_passportsCollection)
            .where('itemId', isEqualTo: itemId)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          final passport = EWastePassport.fromMap(doc.data(), doc.id);
          _localPassports[itemId] = passport;
          return passport;
        }
      } catch (e) {
        debugPrint('[W2V:PassportService] fetchPassport error: $e');
      }
    }

    // Generate a demo passport for item_001
    if (itemId == 'item_001') {
      final demo = EWastePassport(
        passportId: 'W2V-2026-90412',
        itemId: 'item_001',
        deviceTitle: 'Apple MacBook Pro 13" (2019)',
        serialOrImei: 'C02XL8A1MD6R',
        brand: 'Apple',
        model: 'A2159',
        manufacturingYear: 2019,
        composition: const MaterialComposition(
          plasticsPercent: 22.0,
          ferrousMetalsPercent: 28.0,
          copperAndAlloysPercent: 24.0,
          preciousMetalsPercent: 1.8,
          glassAndCeramicsPercent: 18.2,
          batteryCellsPercent: 6.0,
        ),
        carbonFootprintKg: 42.0,
        repairabilityScore: 7.8,
        circularityRatePercent: 94.2,
        hazardousSubstancesFlagged: [
          'Lithium-Polymer Cell (UN3480)',
          'Lead-Free Solder (RoHS Compliant)',
        ],
        qrCodeData: 'W2V-DPP:https://waste2value.org/passport/W2V-2026-90412',
        chainOfCustodyHash: 'SHA256:4f8e91c7a2b0d3e5f617a9c8d1e20345',
        certifyingFacility: 'EcoCycler R2v3 Central Hub, Bangalore',
        licenseNumber: 'R2v3-HUB-88319',
        issuedAt: DateTime.now().subtract(const Duration(days: 2)),
      );
      _localPassports[itemId] = demo;
      return demo;
    }
    return null;
  }

  Future<EWastePassport> savePassport(EWastePassport passport) async {
    _localPassports[passport.itemId] = passport;
    if (FirebaseBootstrap.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_passportsCollection)
            .doc(passport.passportId)
            .set(passport.toMap());
      } catch (e) {
        debugPrint('[W2V:PassportService] savePassport error: $e');
      }
    }
    return passport;
  }

  // ──────────────────── Impact Metrics ────────────────────

  Future<ImpactMetrics> fetchImpactMetrics(String userId) async {
    if (_localMetrics.containsKey(userId)) return _localMetrics[userId]!;

    if (FirebaseBootstrap.isInitialized) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(_impactCollection)
            .doc(userId)
            .get();
        if (doc.exists && doc.data() != null) {
          final metrics = ImpactMetrics.fromMap(doc.data()!, userId);
          _localMetrics[userId] = metrics;
          return metrics;
        }
      } catch (e) {
        debugPrint('[W2V:PassportService] fetchImpact error: $e');
      }
    }

    // Default demo metrics
    final demo = ImpactMetrics(userId: userId);
    _localMetrics[userId] = demo;
    return demo;
  }

  Future<void> updateImpactMetrics(ImpactMetrics metrics) async {
    _localMetrics[metrics.userId] = metrics;
    if (FirebaseBootstrap.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_impactCollection)
            .doc(metrics.userId)
            .set(metrics.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('[W2V:PassportService] updateImpact error: $e');
      }
    }
  }
}
