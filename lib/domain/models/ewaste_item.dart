enum DeviceCategory {
  smartphone('Smartphone / Mobile', '📱', 0.2),
  laptop('Laptop / Notebook', '💻', 2.1),
  tablet('Tablet / iPad', '📟', 0.5),
  desktop('Desktop PC / Workstation', '🖥️', 8.5),
  monitor('Monitor / Display Screen', '🖥️', 4.5),
  battery('Lithium Battery / Power Bank', '🔋', 0.3),
  circuitBoard('PCB / Motherboard', '🎛️', 0.4),
  homeAppliance('Consumer Electronics', '🔌', 3.0),
  cablesAndPeripherals('Cables & Accessories', '🔌', 0.5);

  final String label;
  final String icon;
  final double averageWeightKg;
  const DeviceCategory(this.label, this.icon, this.averageWeightKg);

  static DeviceCategory fromString(String? val) {
    for (var cat in DeviceCategory.values) {
      if (cat.name.toLowerCase() == val?.toLowerCase()) return cat;
    }
    return DeviceCategory.smartphone;
  }
}

enum DeviceCondition {
  flawless('Flawless / Like New', 1.0),
  good('Good with minor scratches', 0.8),
  crackedScreen('Cracked Screen / Display Defect', 0.5),
  heavyWear('Heavy Wear / Casing Damage', 0.35),
  brokenOrDamaged('Damaged / Non-repairable', 0.15);

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

enum FunctionalStatus {
  working('Powers on and fully functional', 1.0),
  partiallyWorking('Powers on with faults (audio/wifi/camera)', 0.6),
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

enum EwasteStatus {
  listed('Listed for Valuation'),
  scheduled('Pickup Scheduled'),
  inTransit('In Transit to Hub'),
  inspected('Inspected & Weighed'),
  recycled('Recycled & Certified');

  final String label;
  const EwasteStatus(this.label);

  static EwasteStatus fromString(String? val) {
    for (var s in EwasteStatus.values) {
      if (s.name.toLowerCase() == val?.toLowerCase()) return s;
    }
    return EwasteStatus.listed;
  }
}

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
        goldGrams: 0.02,
        silverGrams: 0.25,
        copperGrams: 14.0,
        palladiumGrams: 0.008,
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

class EwasteItem {
  final String id;
  final String userId;
  final String title;
  final DeviceCategory category;
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
  final DateTime createdAt;
  final String? serialOrImei;
  final String? notes;

  const EwasteItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
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
    required this.createdAt,
    this.serialOrImei,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'category': category.name,
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
      'createdAt': createdAt.toIso8601String(),
      'serialOrImei': serialOrImei,
      'notes': notes,
    };
  }

  factory EwasteItem.fromMap(Map<String, dynamic> map, String id) {
    return EwasteItem(
      id: id,
      userId: map['userId'] as String? ?? 'user_default',
      title: map['title'] as String? ?? 'Electronic Device',
      category: DeviceCategory.fromString(map['category'] as String?),
      brand: map['brand'] as String? ?? 'Generic',
      model: map['model'] as String? ?? 'Standard',
      purchaseYear: (map['purchaseYear'] as num?)?.toInt() ?? 2021,
      condition: DeviceCondition.fromString(map['condition'] as String?),
      functionalStatus:
          FunctionalStatus.fromString(map['functionalStatus'] as String?),
      estimatedValue: (map['estimatedValue'] as num?)?.toDouble() ?? 25.0,
      carbonSavedKg: (map['carbonSavedKg'] as num?)?.toDouble() ?? 12.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.5,
      preciousMetals: PreciousMetalsEstimate.fromMap(
          map['preciousMetals'] as Map<String, dynamic>?),
      greenCreditsEarned: (map['greenCreditsEarned'] as num?)?.toInt() ?? 40,
      status: EwasteStatus.fromString(map['status'] as String?),
      recommendedAction: map['recommendedAction'] as String? ?? 'Recycle',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      serialOrImei: map['serialOrImei'] as String?,
      notes: map['notes'] as String?,
    );
  }
}
