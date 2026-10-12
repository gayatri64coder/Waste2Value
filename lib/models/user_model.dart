/// User roles in Waste2Value ecosystem
enum UserRole {
  citizen('Eco Citizen'),
  enterprise('Enterprise Generator'),
  recycler('Certified Recycler'),
  collector('Collection Agent'),
  reviewer('Certified Auditor'),
  admin('System Administrator');

  final String label;
  const UserRole(this.label);

  static UserRole fromString(String? role) {
    for (var r in UserRole.values) {
      if (r.name.toLowerCase() == role?.toLowerCase()) return r;
    }
    return UserRole.citizen;
  }
}

/// User model representing a platform participant
class User {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final int greenCredits;
  final double totalKgRecycled;
  final double co2SavedKg;
  final int treesPlantedEquivalent;
  final List<String> badges;
  final String? phoneNumber;
  final String? defaultAddress;
  final String? photoUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.role = UserRole.citizen,
    this.greenCredits = 150,
    this.totalKgRecycled = 14.5,
    this.co2SavedKg = 38.2,
    this.treesPlantedEquivalent = 2,
    this.badges = const ['Urban Miner', 'Battery Guardian', 'Circular Champion'],
    this.phoneNumber,
    this.defaultAddress,
    this.photoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? const _DefaultDate().value;

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    int? greenCredits,
    double? totalKgRecycled,
    double? co2SavedKg,
    int? treesPlantedEquivalent,
    List<String>? badges,
    String? phoneNumber,
    String? defaultAddress,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      greenCredits: greenCredits ?? this.greenCredits,
      totalKgRecycled: totalKgRecycled ?? this.totalKgRecycled,
      co2SavedKg: co2SavedKg ?? this.co2SavedKg,
      treesPlantedEquivalent: treesPlantedEquivalent ?? this.treesPlantedEquivalent,
      badges: badges ?? this.badges,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'greenCredits': greenCredits,
      'totalKgRecycled': totalKgRecycled,
      'co2SavedKg': co2SavedKg,
      'treesPlantedEquivalent': treesPlantedEquivalent,
      'badges': badges,
      'phoneNumber': phoneNumber,
      'defaultAddress': defaultAddress,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      email: map['email'] as String? ?? 'user@waste2value.org',
      displayName: map['displayName'] as String? ?? 'Eco Citizen',
      role: UserRole.fromString(map['role'] as String?),
      greenCredits: (map['greenCredits'] as num?)?.toInt() ?? 0,
      totalKgRecycled: (map['totalKgRecycled'] as num?)?.toDouble() ?? 0.0,
      co2SavedKg: (map['co2SavedKg'] as num?)?.toDouble() ?? 0.0,
      treesPlantedEquivalent: (map['treesPlantedEquivalent'] as num?)?.toInt() ?? 0,
      badges: (map['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      phoneNumber: map['phoneNumber'] as String?,
      defaultAddress: map['defaultAddress'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class _DefaultDate {
  const _DefaultDate();
  DateTime get value => DateTime(2026, 1, 1);
}

typedef AppUser = User;
