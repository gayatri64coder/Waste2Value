/// Grading tier assigned by certified inspector
enum MaterialGrade {
  gradeA('Grade A: High Residual Life / Direct Refurbishment'),
  gradeB('Grade B: Functional Core / Component Harvesting'),
  gradeC('Grade C: Circuit & Critical Metals Hydro-Recovery'),
  gradeD('Grade D: Secondary Pyrometallurgy & Safe Neutralization');

  final String description;
  const MaterialGrade(this.description);

  static MaterialGrade fromString(String? val) {
    for (var g in MaterialGrade.values) {
      if (g.name.toLowerCase() == val?.toLowerCase()) return g;
    }
    return MaterialGrade.gradeB;
  }
}

/// Review model representing inspection, weighing, and verification
class Review {
  final String id;
  final String itemId;
  final String? pickupId;
  final String reviewerId;
  final String reviewerName;
  final double rating;
  final MaterialGrade grading;
  final String comments;
  final double verifiedWeightKg;
  final double adjustedValuation;
  final bool hazardousCheckPassed;
  final bool serialVerified;
  final DateTime reviewedAt;

  const Review({
    required this.id,
    required this.itemId,
    this.pickupId,
    required this.reviewerId,
    required this.reviewerName,
    this.rating = 5.0,
    required this.grading,
    required this.comments,
    required this.verifiedWeightKg,
    required this.adjustedValuation,
    this.hazardousCheckPassed = true,
    this.serialVerified = true,
    required this.reviewedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'pickupId': pickupId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'rating': rating,
      'grading': grading.name,
      'comments': comments,
      'verifiedWeightKg': verifiedWeightKg,
      'adjustedValuation': adjustedValuation,
      'hazardousCheckPassed': hazardousCheckPassed,
      'serialVerified': serialVerified,
      'reviewedAt': reviewedAt.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      itemId: map['itemId'] as String? ?? 'item_001',
      pickupId: map['pickupId'] as String?,
      reviewerId: map['reviewerId'] as String? ?? 'rev_001',
      reviewerName: map['reviewerName'] as String? ?? 'Inspector Rajesh Verma',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      grading: MaterialGrade.fromString(map['grading'] as String?),
      comments: map['comments'] as String? ?? 'Inspected and verified against environmental guidelines.',
      verifiedWeightKg: (map['verifiedWeightKg'] as num?)?.toDouble() ?? 1.4,
      adjustedValuation: (map['adjustedValuation'] as num?)?.toDouble() ?? 245.0,
      hazardousCheckPassed: map['hazardousCheckPassed'] as bool? ?? true,
      serialVerified: map['serialVerified'] as bool? ?? true,
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.tryParse(map['reviewedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
