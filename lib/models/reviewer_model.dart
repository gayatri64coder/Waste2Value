/// Reviewer model representing a certified e-waste inspector or auditor
class Reviewer {
  final String id;
  final String name;
  final String organization;
  final String licenseNumber;
  final String role;
  final String certificationBadge;
  final String email;
  final String phone;
  final DateTime verifiedAt;

  const Reviewer({
    required this.id,
    required this.name,
    required this.organization,
    required this.licenseNumber,
    required this.role,
    required this.certificationBadge,
    required this.email,
    required this.phone,
    required this.verifiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'organization': organization,
      'licenseNumber': licenseNumber,
      'role': role,
      'certificationBadge': certificationBadge,
      'email': email,
      'phone': phone,
      'verifiedAt': verifiedAt.toIso8601String(),
    };
  }

  factory Reviewer.fromMap(Map<String, dynamic> map, String id) {
    return Reviewer(
      id: id,
      name: map['name'] as String? ?? 'Inspector Rajesh Verma',
      organization: map['organization'] as String? ?? 'R2v3 Certified Environmental Labs',
      licenseNumber: map['licenseNumber'] as String? ?? 'AUD-R2V3-9821',
      role: map['role'] as String? ?? 'Senior Material Assessor',
      certificationBadge: map['certificationBadge'] as String? ?? 'Certified R2 Auditor',
      email: map['email'] as String? ?? 'auditor@ecolab.org',
      phone: map['phone'] as String? ?? '+91 80 4321 8899',
      verifiedAt: map['verifiedAt'] != null
          ? DateTime.tryParse(map['verifiedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
