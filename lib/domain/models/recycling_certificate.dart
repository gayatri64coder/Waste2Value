class RecyclingCertificate {
  final String certificateNumber;
  final String userId;
  final String recipientName;
  final String deviceSummary;
  final double totalWeightKg;
  final double co2AvoidedKg;
  final double toxicWasteDivertedGrams;
  final String certifyingFacility;
  final String facilityR2License;
  final DateTime issuedAt;
  final String verificationHash;

  const RecyclingCertificate({
    required this.certificateNumber,
    required this.userId,
    required this.recipientName,
    required this.deviceSummary,
    required this.totalWeightKg,
    required this.co2AvoidedKg,
    required this.toxicWasteDivertedGrams,
    required this.certifyingFacility,
    required this.facilityR2License,
    required this.issuedAt,
    required this.verificationHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'certificateNumber': certificateNumber,
      'userId': userId,
      'recipientName': recipientName,
      'deviceSummary': deviceSummary,
      'totalWeightKg': totalWeightKg,
      'co2AvoidedKg': co2AvoidedKg,
      'toxicWasteDivertedGrams': toxicWasteDivertedGrams,
      'certifyingFacility': certifyingFacility,
      'facilityR2License': facilityR2License,
      'issuedAt': issuedAt.toIso8601String(),
      'verificationHash': verificationHash,
    };
  }

  factory RecyclingCertificate.fromMap(Map<String, dynamic> map) {
    return RecyclingCertificate(
      certificateNumber: map['certificateNumber'] as String? ?? 'W2V-2026-CERT-001',
      userId: map['userId'] as String? ?? 'user_default',
      recipientName: map['recipientName'] as String? ?? 'Eco Citizen',
      deviceSummary: map['deviceSummary'] as String? ?? 'Electronic Waste Assets',
      totalWeightKg: (map['totalWeightKg'] as num?)?.toDouble() ?? 5.4,
      co2AvoidedKg: (map['co2AvoidedKg'] as num?)?.toDouble() ?? 18.2,
      toxicWasteDivertedGrams:
          (map['toxicWasteDivertedGrams'] as num?)?.toDouble() ?? 120.0,
      certifyingFacility:
          map['certifyingFacility'] as String? ?? 'Certified R2 e-Stewards Hub',
      facilityR2License:
          map['facilityR2License'] as String? ?? 'R2v3-CERT-94021',
      issuedAt: map['issuedAt'] != null
          ? DateTime.tryParse(map['issuedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      verificationHash:
          map['verificationHash'] as String? ?? 'SHA256:7e8a9b1c2d3e4f50',
    );
  }
}
