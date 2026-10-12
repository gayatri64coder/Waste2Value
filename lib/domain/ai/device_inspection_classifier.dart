import '../models/ewaste_item.dart';

class InspectionCriteria {
  final String id;
  final String label;
  final String description;
  final bool isDefect;
  final double penaltyWeight;

  const InspectionCriteria({
    required this.id,
    required this.label,
    required this.description,
    required this.isDefect,
    required this.penaltyWeight,
  });
}

class InspectionReport {
  final int confidenceScore; // 0-100%
  final DeviceCondition determinedCondition;
  final FunctionalStatus determinedFunctionalStatus;
  final List<String> flaggedDefects;
  final List<String> passedChecks;
  final String safetyAdvisory;

  const InspectionReport({
    required this.confidenceScore,
    required this.determinedCondition,
    required this.determinedFunctionalStatus,
    required this.flaggedDefects,
    required this.passedChecks,
    required this.safetyAdvisory,
  });
}

/// Offline rule-based device inspection and diagnostic checklist evaluator.
class DeviceInspectionClassifier {
  DeviceInspectionClassifier._();

  static const List<InspectionCriteria> standardChecklist = [
    InspectionCriteria(
      id: 'powers_on',
      label: 'Powers On & Boots into OS',
      description: 'Device powers on without needing constant charger connection',
      isDefect: false,
      penaltyWeight: 0.40,
    ),
    InspectionCriteria(
      id: 'screen_intact',
      label: 'Display Glass & Touch Intact',
      description: 'No spiderweb glass cracks, dead pixels, or touch ghosting',
      isDefect: false,
      penaltyWeight: 0.25,
    ),
    InspectionCriteria(
      id: 'battery_flat',
      label: 'Battery Flat & Not Swollen',
      description: 'Back casing does not bulge; no gap between screen and chassis',
      isDefect: false,
      penaltyWeight: 0.50,
    ),
    InspectionCriteria(
      id: 'ports_working',
      label: 'Charging Port & Connectors Clean',
      description: 'Pins are not corroded or burnt; charges normally',
      isDefect: false,
      penaltyWeight: 0.15,
    ),
    InspectionCriteria(
      id: 'data_wiped',
      label: 'Accounts Logged Out / Data Wiped',
      description: 'iCloud / Google FRP / BitLocker deactivated for recycling',
      isDefect: false,
      penaltyWeight: 0.20,
    ),
  ];

  /// Evaluates an inspection based on checked state of each criterion.
  static InspectionReport evaluateChecks({
    required Map<String, bool> checkResults,
    required bool hasSwollenBatteryReported,
  }) {
    final List<String> passed = [];
    final List<String> defects = [];
    double healthScore = 100.0;

    for (final criterion in standardChecklist) {
      final isPassing = checkResults[criterion.id] ?? false;
      if (isPassing) {
        passed.add(criterion.label);
      } else {
        defects.add(criterion.label);
        healthScore -= (criterion.penaltyWeight * 100);
      }
    }

    if (hasSwollenBatteryReported) {
      defects.add('⚠️ Swollen Lithium-Ion Cell Detected');
      healthScore = (healthScore - 40).clamp(0, 100);
    }

    final int finalConfidence = healthScore.clamp(10, 100).toInt();

    DeviceCondition cond;
    FunctionalStatus func;
    String advisory;

    if (hasSwollenBatteryReported || !(checkResults['battery_flat'] ?? true)) {
      cond = DeviceCondition.brokenOrDamaged;
      func = FunctionalStatus.hazardousBattery;
      advisory =
          'CRITICAL SAFETY ADVISORY: Do not attempt to charge or press on the device. Isolate in fire-resistant container.';
    } else if (finalConfidence >= 90) {
      cond = DeviceCondition.flawless;
      func = FunctionalStatus.working;
      advisory = 'Optimal condition: Qualified for highest valuation and refurbishment stream.';
    } else if (finalConfidence >= 70) {
      cond = DeviceCondition.good;
      func = FunctionalStatus.working;
      advisory = 'Standard good condition: Minor cosmetic wear, eligible for reuse or parts recovery.';
    } else if (finalConfidence >= 45) {
      cond = DeviceCondition.crackedScreen;
      func = (checkResults['powers_on'] ?? false)
          ? FunctionalStatus.partiallyWorking
          : FunctionalStatus.dead;
      advisory = 'Defective or worn unit: Eligible for component harvesting and circuit board recovery.';
    } else {
      cond = DeviceCondition.brokenOrDamaged;
      func = FunctionalStatus.dead;
      advisory = 'Scrap-grade unit: Direct smelting for gold, silver, and copper extraction.';
    }

    return InspectionReport(
      confidenceScore: finalConfidence,
      determinedCondition: cond,
      determinedFunctionalStatus: func,
      flaggedDefects: defects,
      passedChecks: passed,
      safetyAdvisory: advisory,
    );
  }
}
