/// ImpactMetrics model aggregating personal and community ecological abatement
class ImpactMetrics {
  final String userId;
  final double totalKgRecycled;
  final double co2SavedKg;
  final int treesPlantedEquivalent;
  final double goldGramsRecovered;
  final double silverGramsRecovered;
  final double copperGramsRecovered;
  final double palladiumGramsRecovered;
  final double toxicWasteDivertedGrams;
  final double energySavedKwh;
  final double landfillSpaceSavedM3;
  final int itemsDivertedCount;
  final int certificatesCount;
  final int greenCreditsEarned;
  final int globalRank;
  final int citiesImpacted;
  final int localJobsSupported;

  const ImpactMetrics({
    required this.userId,
    this.totalKgRecycled = 28.4,
    this.co2SavedKg = 86.5,
    this.treesPlantedEquivalent = 4,
    this.goldGramsRecovered = 0.43,
    this.silverGramsRecovered = 2.65,
    this.copperGramsRecovered = 745.0,
    this.palladiumGramsRecovered = 0.07,
    this.toxicWasteDivertedGrams = 310.0,
    this.energySavedKwh = 195.0,
    this.landfillSpaceSavedM3 = 0.24,
    this.itemsDivertedCount = 8,
    this.certificatesCount = 3,
    this.greenCreditsEarned = 380,
    this.globalRank = 2847,
    this.citiesImpacted = 2,
    this.localJobsSupported = 4,
  });

  /// Total items recycled (alias for itemsDivertedCount)
  int get itemsRecycled => itemsDivertedCount;

  /// Total precious metals recovered in grams
  double get preciousMetalsRecoveredGrams =>
      goldGramsRecovered + silverGramsRecovered + copperGramsRecovered + palladiumGramsRecovered;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalKgRecycled': totalKgRecycled,
      'co2SavedKg': co2SavedKg,
      'treesPlantedEquivalent': treesPlantedEquivalent,
      'goldGramsRecovered': goldGramsRecovered,
      'silverGramsRecovered': silverGramsRecovered,
      'copperGramsRecovered': copperGramsRecovered,
      'palladiumGramsRecovered': palladiumGramsRecovered,
      'toxicWasteDivertedGrams': toxicWasteDivertedGrams,
      'energySavedKwh': energySavedKwh,
      'landfillSpaceSavedM3': landfillSpaceSavedM3,
      'itemsDivertedCount': itemsDivertedCount,
      'certificatesCount': certificatesCount,
      'greenCreditsEarned': greenCreditsEarned,
      'globalRank': globalRank,
      'citiesImpacted': citiesImpacted,
      'localJobsSupported': localJobsSupported,
    };
  }

  factory ImpactMetrics.fromMap(Map<String, dynamic> map, String userId) {
    return ImpactMetrics(
      userId: userId,
      totalKgRecycled: (map['totalKgRecycled'] as num?)?.toDouble() ?? 0.0,
      co2SavedKg: (map['co2SavedKg'] as num?)?.toDouble() ?? 0.0,
      treesPlantedEquivalent: (map['treesPlantedEquivalent'] as num?)?.toInt() ?? 0,
      goldGramsRecovered: (map['goldGramsRecovered'] as num?)?.toDouble() ?? 0.0,
      silverGramsRecovered: (map['silverGramsRecovered'] as num?)?.toDouble() ?? 0.0,
      copperGramsRecovered: (map['copperGramsRecovered'] as num?)?.toDouble() ?? 0.0,
      palladiumGramsRecovered: (map['palladiumGramsRecovered'] as num?)?.toDouble() ?? 0.0,
      toxicWasteDivertedGrams: (map['toxicWasteDivertedGrams'] as num?)?.toDouble() ?? 0.0,
      energySavedKwh: (map['energySavedKwh'] as num?)?.toDouble() ?? 0.0,
      landfillSpaceSavedM3: (map['landfillSpaceSavedM3'] as num?)?.toDouble() ?? 0.0,
      itemsDivertedCount: (map['itemsDivertedCount'] as num?)?.toInt() ?? 0,
      certificatesCount: (map['certificatesCount'] as num?)?.toInt() ?? 0,
      greenCreditsEarned: (map['greenCreditsEarned'] as num?)?.toInt() ?? 0,
      globalRank: (map['globalRank'] as num?)?.toInt() ?? 9999,
      citiesImpacted: (map['citiesImpacted'] as num?)?.toInt() ?? 1,
      localJobsSupported: (map['localJobsSupported'] as num?)?.toInt() ?? 1,
    );
  }
}
