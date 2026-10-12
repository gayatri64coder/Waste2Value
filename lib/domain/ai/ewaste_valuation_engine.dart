import '../models/ewaste_item.dart';

class ValuationResult {
  final double estimatedValue;
  final double carbonSavedKg;
  final double weightKg;
  final PreciousMetalsEstimate preciousMetals;
  final int greenCredits;
  final int recyclabilityScore; // 0-100
  final String hazardLevel; // 'None', 'Low', 'Medium', 'High / Urgent'
  final String primaryRecommendation;
  final List<String> actionableInsights;
  final bool requiresHazardousHandling;

  const ValuationResult({
    required this.estimatedValue,
    required this.carbonSavedKg,
    required this.weightKg,
    required this.preciousMetals,
    required this.greenCredits,
    required this.recyclabilityScore,
    required this.hazardLevel,
    required this.primaryRecommendation,
    required this.actionableInsights,
    required this.requiresHazardousHandling,
  });
}

/// Offline, zero-cost rule-based recommendation & valuation engine for e-waste.
class EwasteValuationEngine {
  EwasteValuationEngine._();

  /// Calculates real-world valuation, environmental carbon credits,
  /// and precious metal recovery metrics based on category, condition, and age.
  static ValuationResult evaluate({
    required DeviceCategory category,
    required String brand,
    required int purchaseYear,
    required DeviceCondition condition,
    required FunctionalStatus functionalStatus,
    String? additionalNotes,
  }) {
    final currentYear = DateTime.now().year;
    final ageYears = (currentYear - purchaseYear).clamp(0, 20);

    // 1. Base device value by category (estimated baseline in USD / credit equivalence)
    double baseValue;
    double baseCarbonKg;
    double weightKg = category.averageWeightKg;
    PreciousMetalsEstimate metals;

    switch (category) {
      case DeviceCategory.smartphone:
        baseValue = 180.0;
        baseCarbonKg = 16.5;
        metals = const PreciousMetalsEstimate(
          goldGrams: 0.034,
          silverGrams: 0.35,
          copperGrams: 15.0,
          palladiumGrams: 0.015,
        );
        break;
      case DeviceCategory.laptop:
        baseValue = 350.0;
        baseCarbonKg = 42.0;
        metals = const PreciousMetalsEstimate(
          goldGrams: 0.18,
          silverGrams: 1.2,
          copperGrams: 450.0,
          palladiumGrams: 0.05,
        );
        break;
      case DeviceCategory.tablet:
        baseValue = 140.0;
        baseCarbonKg = 21.0;
        metals = const PreciousMetalsEstimate(
          goldGrams: 0.05,
          silverGrams: 0.45,
          copperGrams: 80.0,
          palladiumGrams: 0.02,
        );
        break;
      case DeviceCategory.desktop:
        baseValue = 280.0;
        baseCarbonKg = 75.0;
        metals = const PreciousMetalsEstimate(
          goldGrams: 0.25,
          silverGrams: 1.8,
          copperGrams: 850.0,
          palladiumGrams: 0.08,
        );
        break;
      case DeviceCategory.monitor:
        baseValue = 90.0;
        baseCarbonKg = 30.0;
        metals = const PreciousMetalsEstimate(
          goldGrams: 0.02,
          silverGrams: 0.15,
          copperGrams: 220.0,
          palladiumGrams: 0.005,
        );
        break;
      case DeviceCategory.battery:
        baseValue = 20.0;
        baseCarbonKg = 8.5;
        metals = const PreciousMetalsEstimate(
          goldGrams: 0.0,
          silverGrams: 0.0,
          copperGrams: 35.0,
          palladiumGrams: 0.0,
        );
        break;
      case DeviceCategory.circuitBoard:
        baseValue = 45.0;
        baseCarbonKg = 18.0;
        metals = const PreciousMetalsEstimate(
          goldGrams: 0.12,
          silverGrams: 0.8,
          copperGrams: 180.0,
          palladiumGrams: 0.03,
        );
        break;
      case DeviceCategory.homeAppliance:
        baseValue = 60.0;
        baseCarbonKg = 25.0;
        metals = const PreciousMetalsEstimate(
          goldGrams: 0.01,
          silverGrams: 0.1,
          copperGrams: 320.0,
          palladiumGrams: 0.0,
        );
        break;
      case DeviceCategory.cablesAndPeripherals:
        baseValue = 12.0;
        baseCarbonKg = 5.0;
        metals = const PreciousMetalsEstimate(
          goldGrams: 0.005,
          silverGrams: 0.05,
          copperGrams: 120.0,
          palladiumGrams: 0.0,
        );
        break;
    }

    // 2. Premium brand multiplier
    final b = brand.toLowerCase();
    double brandMultiplier = 1.0;
    if (b.contains('apple') || b.contains('iphone') || b.contains('macbook')) {
      brandMultiplier = 1.35;
    } else if (b.contains('samsung') ||
        b.contains('dell') ||
        b.contains('lenovo') ||
        b.contains('hp') ||
        b.contains('sony')) {
      brandMultiplier = 1.15;
    }

    // 3. Age depreciation decay curve (15% annual decay, floor at 10% scrap floor)
    final ageDecay = (1.0 - (ageYears * 0.14)).clamp(0.12, 1.0);

    // 4. Compute final valuation with condition and functional multipliers
    double calculatedValue = baseValue *
        brandMultiplier *
        ageDecay *
        condition.valuationMultiplier *
        functionalStatus.multiplier;

    // Minimum scrap metal floor value for any electronic item
    if (calculatedValue < 5.0) {
      calculatedValue = (metals.goldGrams * 65.0) +
          (metals.copperGrams * 0.009) +
          (weightKg * 1.5);
    }
    calculatedValue = (calculatedValue * 100).roundToDouble() / 100;

    // 5. Environmental carbon savings and green credits
    final double carbonSaved = (baseCarbonKg *
        (0.85 + (condition.valuationMultiplier * 0.25)));
    final int credits = (calculatedValue * 1.5 + carbonSaved * 2.0).toInt().clamp(10, 1000);

    // 6. Recyclability score & Hazard analysis
    int recyclability = 85;
    String hazard = 'Low';
    bool requiresHazard = false;
    final List<String> insights = [];

    if (functionalStatus == FunctionalStatus.hazardousBattery ||
        category == DeviceCategory.battery) {
      hazard = 'High / Urgent';
      requiresHazard = true;
      recyclability = 60;
      insights.add(
        '⚠️ Swollen/damaged lithium batteries must NOT be punctured or exposed to heat. Store in non-conductive sand or antistatic bag.',
      );
    } else if (category == DeviceCategory.monitor) {
      hazard = 'Medium';
      insights.add(
        'Contains phosphor coating or CCFL fluorescent tubes. Certified handling prevents mercury vapor release.',
      );
    } else if (condition == DeviceCondition.brokenOrDamaged) {
      hazard = 'Medium';
      insights.add('Exposed sharp glass or internal wiring detected. Handle with protective gloves.');
    } else {
      hazard = 'Safe';
      insights.add('Components are intact and suitable for standard handling.');
    }

    // 7. Recommendation logic
    String recommendation;
    if (requiresHazard) {
      recommendation = 'Hazardous Material Safe Containment & Priority Recycling';
    } else if (functionalStatus == FunctionalStatus.working &&
        (condition == DeviceCondition.flawless ||
            condition == DeviceCondition.good) &&
        ageYears <= 4) {
      recommendation =
          'Refurbish & Reuse (Maximum Economic Return - Eligible for Green Voucher)';
      insights.add('Device is in high-grade functional condition. Refurbishment yields 3x higher value than scrap.');
      insights.add('Remember to perform a full factory reset and sign out of cloud accounts.');
    } else if (functionalStatus == FunctionalStatus.working ||
        functionalStatus == FunctionalStatus.partiallyWorking) {
      recommendation = 'Parts Harvesting & Circular Component Resale';
      insights.add('Screen, camera module, or internal memory chips can be harvested for certified repair stocks.');
    } else {
      recommendation = 'Certified Precious Metal Recovery & Eco Smelting';
      insights.add(
        'Estimated to extract ${(metals.goldGrams * 1000).toStringAsFixed(1)}mg Gold, ${(metals.copperGrams).toStringAsFixed(0)}g Copper, preventing landfill toxic runoff.',
      );
    }

    return ValuationResult(
      estimatedValue: calculatedValue,
      carbonSavedKg: (carbonSaved * 10).roundToDouble() / 10,
      weightKg: weightKg,
      preciousMetals: metals,
      greenCredits: credits,
      recyclabilityScore: recyclability,
      hazardLevel: hazard,
      primaryRecommendation: recommendation,
      actionableInsights: insights,
      requiresHazardousHandling: requiresHazard,
    );
  }
}
