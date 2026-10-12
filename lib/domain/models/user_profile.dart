enum UserRole {
  citizen('Eco Citizen'),
  business('Enterprise Generator'),
  recycler('Certified Recycler'),
  collector('Collection Agent'),
  admin('System Administrator');

  final String label;
  const UserRole(this.label);

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'business':
      case 'enterprise':
        return UserRole.business;
      case 'recycler':
        return UserRole.recycler;
      case 'collector':
        return UserRole.collector;
      case 'admin':
        return UserRole.admin;
      case 'citizen':
      default:
        return UserRole.citizen;
    }
  }
}

class UserProfile {
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

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.role = UserRole.citizen,
    this.greenCredits = 150,
    this.totalKgRecycled = 14.5,
    this.co2SavedKg = 42.8,
    this.treesPlantedEquivalent = 2,
    this.badges = const [
      'Early Recycler',
      'Battery Saver',
      'Circular Champion',
    ],
    this.phoneNumber,
    this.defaultAddress,
  });

  UserProfile copyWith({
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
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      greenCredits: greenCredits ?? this.greenCredits,
      totalKgRecycled: totalKgRecycled ?? this.totalKgRecycled,
      co2SavedKg: co2SavedKg ?? this.co2SavedKg,
      treesPlantedEquivalent:
          treesPlantedEquivalent ?? this.treesPlantedEquivalent,
      badges: badges ?? this.badges,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      defaultAddress: defaultAddress ?? this.defaultAddress,
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
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      email: map['email'] as String? ?? 'user@waste2value.org',
      displayName: map['displayName'] as String? ?? 'Eco Citizen',
      role: UserRole.fromString(map['role'] as String?),
      greenCredits: (map['greenCredits'] as num?)?.toInt() ?? 0,
      totalKgRecycled: (map['totalKgRecycled'] as num?)?.toDouble() ?? 0.0,
      co2SavedKg: (map['co2SavedKg'] as num?)?.toDouble() ?? 0.0,
      treesPlantedEquivalent:
          (map['treesPlantedEquivalent'] as num?)?.toInt() ?? 0,
      badges: (map['badges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      phoneNumber: map['phoneNumber'] as String?,
      defaultAddress: map['defaultAddress'] as String?,
    );
  }
}
