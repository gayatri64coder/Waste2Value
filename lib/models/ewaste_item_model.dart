/// Device condition assessment
enum DeviceCondition {
  flawless('Flawless / Like New', 1.0),
  good('Good with minor wear', 0.8),
  crackedScreen('Screen / Display Damaged', 0.5),
  heavyWear('Heavy Wear / Casing Cracked', 0.35),
  brokenOrDamaged('Damaged / Non-functional', 0.15);

  final String label;
  final double valuationMultiplier;
  const DeviceCondition(this.label, this.valuationMultiplier);

  static DeviceCondition fromString(String? val) {
    for (var cond in DeviceCondition.values) {
      if (cond.name.toLowerCase() == val?.toLowerCase()) return cond;
    }
    return DeviceCondition.good;
  }
}

/// Functional status of hardware
enum FunctionalStatus {
  working('Powers on and fully functional', 1.0),
  partiallyWorking('Powers on with faults (audio/touch/wifi)', 0.6),
  dead('Dead / Does not power on', 0.25),
  hazardousBattery('Swollen / Damaged Battery (Alert)', 0.1);

  final String label;
  final double multiplier;
  const FunctionalStatus(this.label, this.multiplier);

  static FunctionalStatus fromString(String? val) {
    for (var st in FunctionalStatus.values) {
      if (st.name.toLowerCase() == val?.toLowerCase()) return st;
    }
    return FunctionalStatus.working;
  }
}

/// Lifecycle status of e-waste item
enum EwasteStatus {
  submitted('Submitted for Evaluation'),
  verified('Verified by Inspector'),
  pickupScheduled('Pickup Scheduled'),
  inTransit('In Transit to Hub'),
  arrivedAtFacility('Arrived at Recycling Facility'),
  recycled('Recycled & Certified'),
  repaired('Repaired / Reused');

  final String label;
  const EwasteStatus(this.label);

  static EwasteStatus fromString(String? val) {
    for (var s in EwasteStatus.values) {
      if (s.name.toLowerCase() == val?.toLowerCase()) return s;
    }
    return EwasteStatus.submitted;
  }
}

/// Estimated recovery quantities of valuable critical raw materials
class PreciousMetalsEstimate {
  final double goldGrams;
  final double silverGrams;
  final double copperGrams;
  final double palladiumGrams;

  const PreciousMetalsEstimate({
    required this.goldGrams,
    required this.silverGrams,
    required this.copperGrams,
    required this.palladiumGrams,
  });

  Map<String, dynamic> toMap() => {
        'goldGrams': goldGrams,
        'silverGrams': silverGrams,
        'copperGrams': copperGrams,
        'palladiumGrams': palladiumGrams,
      };

  factory PreciousMetalsEstimate.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const PreciousMetalsEstimate(
        goldGrams: 0.03,
        silverGrams: 0.35,
        copperGrams: 20.0,
        palladiumGrams: 0.01,
      );
    }
    return PreciousMetalsEstimate(
      goldGrams: (map['goldGrams'] as num?)?.toDouble() ?? 0.0,
      silverGrams: (map['silverGrams'] as num?)?.toDouble() ?? 0.0,
      copperGrams: (map['copperGrams'] as num?)?.toDouble() ?? 0.0,
      palladiumGrams: (map['palladiumGrams'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// EWasteItem model representing an electronic asset submitted for circular recycling
class EWasteItem {
  final String id;
  final String userId;
  final String title;
  final String categoryId;
  final String categoryName;
  final String brand;
  final String model;
  final int purchaseYear;
  final DeviceCondition condition;
  final FunctionalStatus functionalStatus;
  final double estimatedValue;
  final double carbonSavedKg;
  final double weightKg;
  final PreciousMetalsEstimate preciousMetals;
  final int greenCreditsEarned;
  final EwasteStatus status;
  final String recommendedAction;
  final String? serialNumber;
  final String? passportId;
  final String? notes;
  final DateTime createdAt;

  const EWasteItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.brand,
    required this.model,
    required this.purchaseYear,
    required this.condition,
    required this.functionalStatus,
    required this.estimatedValue,
    required this.carbonSavedKg,
    required this.weightKg,
    required this.preciousMetals,
    required this.greenCreditsEarned,
    required this.status,
    required this.recommendedAction,
    this.serialNumber,
    this.passportId,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'brand': brand,
      'model': model,
      'purchaseYear': purchaseYear,
      'condition': condition.name,
      'functionalStatus': functionalStatus.name,
      'estimatedValue': estimatedValue,
      'carbonSavedKg': carbonSavedKg,
      'weightKg': weightKg,
      'preciousMetals': preciousMetals.toMap(),
      'greenCreditsEarned': greenCreditsEarned,
      'status': status.name,
      'recommendedAction': recommendedAction,
      'serialNumber': serialNumber,
      'passportId': passportId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EWasteItem.fromMap(Map<String, dynamic> map, String id) {
    return EWasteItem(
      id: id,
      userId: map['userId'] as String? ?? 'user_default',
      title: map['title'] as String? ?? 'Electronic Device',
      categoryId: map['categoryId'] as String? ?? 'cat_smartphones',
      categoryName: map['categoryName'] as String? ?? 'Smartphones',
      brand: map['brand'] as String? ?? 'Generic',
      model: map['model'] as String? ?? 'Standard',
      purchaseYear: (map['purchaseYear'] as num?)?.toInt() ?? 2021,
      condition: DeviceCondition.fromString(map['condition'] as String?),
      functionalStatus: FunctionalStatus.fromString(map['functionalStatus'] as String?),
      estimatedValue: (map['estimatedValue'] as num?)?.toDouble() ?? 30.0,
      carbonSavedKg: (map['carbonSavedKg'] as num?)?.toDouble() ?? 14.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.5,
      preciousMetals: PreciousMetalsEstimate.fromMap(map['preciousMetals'] as Map<String, dynamic>?),
      greenCreditsEarned: (map['greenCreditsEarned'] as num?)?.toInt() ?? 50,
      status: EwasteStatus.fromString(map['status'] as String?),
      recommendedAction: map['recommendedAction'] as String? ?? 'Recycle Responsibly',
      serialNumber: map['serialNumber'] as String?,
      passportId: map['passportId'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
