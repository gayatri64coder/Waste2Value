/// Reward model representing redeemable perks and eco-coupons
class Reward {
  final String id;
  final String title;
  final String description;
  final String partnerName;
  final int pointsCost;
  final double? discountPercentage;
  final String voucherCode;
  final String category;
  final DateTime expiryDate;
  final String icon;
  final String terms;
  final bool isAvailable;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.partnerName,
    required this.pointsCost,
    this.discountPercentage,
    required this.voucherCode,
    required this.category,
    required this.expiryDate,
    required this.icon,
    required this.terms,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'partnerName': partnerName,
      'pointsCost': pointsCost,
      'discountPercentage': discountPercentage,
      'voucherCode': voucherCode,
      'category': category,
      'expiryDate': expiryDate.toIso8601String(),
      'icon': icon,
      'terms': terms,
      'isAvailable': isAvailable,
    };
  }

  factory Reward.fromMap(Map<String, dynamic> map, String id) {
    return Reward(
      id: id,
      title: map['title'] as String? ?? 'Eco Reward',
      description: map['description'] as String? ?? '',
      partnerName: map['partnerName'] as String? ?? 'Green Partner',
      pointsCost: (map['pointsCost'] as num?)?.toInt() ?? 100,
      discountPercentage: (map['discountPercentage'] as num?)?.toDouble(),
      voucherCode: map['voucherCode'] as String? ?? 'ECO-VOUCHER',
      category: map['category'] as String? ?? 'Circular Store',
      expiryDate: map['expiryDate'] != null
          ? DateTime.tryParse(map['expiryDate'].toString()) ?? DateTime.now().add(const Duration(days: 90))
          : DateTime.now().add(const Duration(days: 90)),
      icon: map['icon'] as String? ?? '🎁',
      terms: map['terms'] as String? ?? 'Valid on all certified refurbished purchases.',
      isAvailable: map['isAvailable'] as bool? ?? true,
    );
  }

  static const List<Reward> defaultRewards = [
    Reward(
      id: 'rew_001',
      title: '\$25 Off Refurbished Laptops',
      description: 'Get \$25 discount on certified refurbished laptops with 1-year warranty.',
      partnerName: 'CircularByte Electronics',
      pointsCost: 150,
      discountPercentage: 15.0,
      voucherCode: 'CIRCULAR-LAPTOP-25',
      category: 'Electronics',
      expiryDate: _RewardDefaultDate.date,
      icon: '💻',
      terms: 'Applicable on orders above \$150. Valid for 90 days from redemption.',
    ),
    Reward(
      id: 'rew_002',
      title: 'Plant 5 Urban Trees',
      description: 'Fund 5 native trees planted and tracked via geo-tagged satellite monitoring.',
      partnerName: 'OneTreePlanted Foundation',
      pointsCost: 100,
      voucherCode: 'TREE-HERO-5X',
      category: 'Climate Impact',
      expiryDate: _RewardDefaultDate.date,
      icon: '🌳',
      terms: 'Direct contribution to SDG 13 & SDG 15 reforestation initiatives.',
    ),
    Reward(
      id: 'rew_003',
      title: 'Free Antistatic Battery Safe Pouch',
      description: 'Receive a certified flame-resistant pouch for safely storing lithium batteries.',
      partnerName: 'SafeRecycle India',
      pointsCost: 80,
      voucherCode: 'SAFE-POUCH-FREE',
      category: 'Safety Gear',
      expiryDate: _RewardDefaultDate.date,
      icon: '🔋',
      terms: 'Free doorstep shipping included for verified eco citizens.',
    ),
    Reward(
      id: 'rew_004',
      title: '20% Off Solar Power Banks',
      description: 'High-efficiency monocrystalline portable solar chargers.',
      partnerName: 'Solaris Clean Energy',
      pointsCost: 120,
      discountPercentage: 20.0,
      voucherCode: 'SOLAR-20-POWER',
      category: 'Clean Energy',
      expiryDate: _RewardDefaultDate.date,
      icon: '☀️',
      terms: 'Valid across Solaris online and partner retail stores.',
    ),
  ];
}

class _RewardDefaultDate {
  static final DateTime date = DateTime(2026, 12, 31);
}
