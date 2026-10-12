/// Material composition percentage breakdown in Digital Product Passport
class MaterialComposition {
  final double plasticsPercent;
  final double ferrousMetalsPercent;
  final double copperAndAlloysPercent;
  final double preciousMetalsPercent;
  final double glassAndCeramicsPercent;
  final double batteryCellsPercent;

  const MaterialComposition({
    this.plasticsPercent = 28.5,
    this.ferrousMetalsPercent = 32.0,
    this.copperAndAlloysPercent = 18.0,
    this.preciousMetalsPercent = 1.2,
    this.glassAndCeramicsPercent = 14.3,
    this.batteryCellsPercent = 6.0,
  });

  Map<String, dynamic> toMap() => {
        'plasticsPercent': plasticsPercent,
        'ferrousMetalsPercent': ferrousMetalsPercent,
        'copperAndAlloysPercent': copperAndAlloysPercent,
        'preciousMetalsPercent': preciousMetalsPercent,
        'glassAndCeramicsPercent': glassAndCeramicsPercent,
        'batteryCellsPercent': batteryCellsPercent,
      };

  factory MaterialComposition.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const MaterialComposition();
    return MaterialComposition(
      plasticsPercent: (map['plasticsPercent'] as num?)?.toDouble() ?? 28.5,
      ferrousMetalsPercent: (map['ferrousMetalsPercent'] as num?)?.toDouble() ?? 32.0,
      copperAndAlloysPercent: (map['copperAndAlloysPercent'] as num?)?.toDouble() ?? 18.0,
      preciousMetalsPercent: (map['preciousMetalsPercent'] as num?)?.toDouble() ?? 1.2,
      glassAndCeramicsPercent: (map['glassAndCeramicsPercent'] as num?)?.toDouble() ?? 14.3,
      batteryCellsPercent: (map['batteryCellsPercent'] as num?)?.toDouble() ?? 6.0,
    );
  }
}

/// Digital Product Passport (DPP) aligned with SDG 12 and Circular Economy directives
class EWastePassport {
  final String passportId;
  final String itemId;
  final String deviceTitle;
  final String serialOrImei;
  final String brand;
  final String model;
  final int manufacturingYear;
  final MaterialComposition composition;
  final double carbonFootprintKg;
  final double repairabilityScore; // Scale 1.0 - 10.0
  final double circularityRatePercent; // e.g. 92.4% recyclable
  final List<String> hazardousSubstancesFlagged;
  final String qrCodeData;
  final String chainOfCustodyHash;
  final String certifyingFacility;
  final String licenseNumber;
  final DateTime issuedAt;

  const EWastePassport({
    required this.passportId,
    required this.itemId,
    required this.deviceTitle,
    required this.serialOrImei,
    required this.brand,
    required this.model,
    required this.manufacturingYear,
    required this.composition,
    required this.carbonFootprintKg,
    required this.repairabilityScore,
    required this.circularityRatePercent,
    required this.hazardousSubstancesFlagged,
    required this.qrCodeData,
    required this.chainOfCustodyHash,
    required this.certifyingFacility,
    required this.licenseNumber,
    required this.issuedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'passportId': passportId,
      'itemId': itemId,
      'deviceTitle': deviceTitle,
      'serialOrImei': serialOrImei,
      'brand': brand,
      'model': model,
      'manufacturingYear': manufacturingYear,
      'composition': composition.toMap(),
      'carbonFootprintKg': carbonFootprintKg,
      'repairabilityScore': repairabilityScore,
      'circularityRatePercent': circularityRatePercent,
      'hazardousSubstancesFlagged': hazardousSubstancesFlagged,
      'qrCodeData': qrCodeData,
      'chainOfCustodyHash': chainOfCustodyHash,
      'certifyingFacility': certifyingFacility,
      'licenseNumber': licenseNumber,
      'issuedAt': issuedAt.toIso8601String(),
    };
  }

  factory EWastePassport.fromMap(Map<String, dynamic> map, String id) {
    return EWastePassport(
      passportId: id,
      itemId: map['itemId'] as String? ?? 'item_001',
      deviceTitle: map['deviceTitle'] as String? ?? 'Apple MacBook Pro 13"',
      serialOrImei: map['serialOrImei'] as String? ?? 'SN-C02XL8A1MD6R',
      brand: map['brand'] as String? ?? 'Apple',
      model: map['model'] as String? ?? 'A2159',
      manufacturingYear: (map['manufacturingYear'] as num?)?.toInt() ?? 2019,
      composition: MaterialComposition.fromMap(map['composition'] as Map<String, dynamic>?),
      carbonFootprintKg: (map['carbonFootprintKg'] as num?)?.toDouble() ?? 42.0,
      repairabilityScore: (map['repairabilityScore'] as num?)?.toDouble() ?? 7.8,
      circularityRatePercent: (map['circularityRatePercent'] as num?)?.toDouble() ?? 94.2,
      hazardousSubstancesFlagged: (map['hazardousSubstancesFlagged'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Lithium-Polymer Cell (UN3480)', 'Lead-Free Soldering (RoHS Compliant)'],
      qrCodeData: map['qrCodeData'] as String? ?? 'W2V-DPP:https://waste2value.org/passport/W2V-2026-90412',
      chainOfCustodyHash: map['chainOfCustodyHash'] as String? ?? 'SHA256:4f8e91c7a2b0d3e5f617',
      certifyingFacility: map['certifyingFacility'] as String? ?? 'EcoCycler R2v3 Central Hub',
      licenseNumber: map['licenseNumber'] as String? ?? 'R2v3-HUB-88319',
      issuedAt: map['issuedAt'] != null
          ? DateTime.tryParse(map['issuedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
