/// Category model for categorizing electronic waste
class Category {
  final String id;
  final String name;
  final String icon;
  final double averageWeightKg;
  final double baseValuationPerKg;
  final String description;
  final String sdgTarget;
  final bool hasPreciousMetals;
  final bool containsHazardousMaterials;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.averageWeightKg,
    required this.baseValuationPerKg,
    required this.description,
    this.sdgTarget = 'SDG 12',
    this.hasPreciousMetals = true,
    this.containsHazardousMaterials = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'averageWeightKg': averageWeightKg,
      'baseValuationPerKg': baseValuationPerKg,
      'description': description,
      'sdgTarget': sdgTarget,
      'hasPreciousMetals': hasPreciousMetals,
      'containsHazardousMaterials': containsHazardousMaterials,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: map['name'] as String? ?? 'Electronics',
      icon: map['icon'] as String? ?? '📱',
      averageWeightKg: (map['averageWeightKg'] as num?)?.toDouble() ?? 1.0,
      baseValuationPerKg: (map['baseValuationPerKg'] as num?)?.toDouble() ?? 50.0,
      description: map['description'] as String? ?? '',
      sdgTarget: map['sdgTarget'] as String? ?? 'SDG 12',
      hasPreciousMetals: map['hasPreciousMetals'] as bool? ?? true,
      containsHazardousMaterials: map['containsHazardousMaterials'] as bool? ?? true,
    );
  }

  /// Default categories available in Waste2Value
  static const List<Category> defaultCategories = [
    Category(
      id: 'cat_smartphones',
      name: 'Smartphones & Tablets',
      icon: '📱',
      averageWeightKg: 0.22,
      baseValuationPerKg: 280.0,
      description: 'Mobile phones, phablets, tablets, and e-readers rich in gold and cobalt.',
      sdgTarget: 'SDG 12',
    ),
    Category(
      id: 'cat_laptops',
      name: 'Laptops & Computers',
      icon: '💻',
      averageWeightKg: 2.3,
      baseValuationPerKg: 160.0,
      description: 'Notebooks, MacBooks, desktops, mini PCs, and high-value internal PCBs.',
      sdgTarget: 'SDG 12',
    ),
    Category(
      id: 'cat_displays',
      name: 'Monitors & Displays',
      icon: '🖥️',
      averageWeightKg: 4.8,
      baseValuationPerKg: 45.0,
      description: 'LED, LCD, and OLED displays requiring safe mercury/phosphor handling.',
      sdgTarget: 'SDG 11',
    ),
    Category(
      id: 'cat_batteries',
      name: 'Batteries & Power Banks',
      icon: '🔋',
      averageWeightKg: 0.35,
      baseValuationPerKg: 95.0,
      description: 'Lithium-ion, NiMH, and power banks requiring anti-thermal puncture protocols.',
      sdgTarget: 'SDG 13',
    ),
    Category(
      id: 'cat_pcbs',
      name: 'PCBs & Motherboards',
      icon: '🎛️',
      averageWeightKg: 0.45,
      baseValuationPerKg: 320.0,
      description: 'High-grade telecom boards, server motherboards, RAM, and gold-plated CPUs.',
      sdgTarget: 'SDG 12',
    ),
    Category(
      id: 'cat_appliances',
      name: 'Small Appliances & Audio',
      icon: '🔌',
      averageWeightKg: 2.8,
      baseValuationPerKg: 35.0,
      description: 'Microwaves, coffee machines, headphones, smart speakers, and consoles.',
      sdgTarget: 'SDG 12',
    ),
    Category(
      id: 'cat_cables',
      name: 'Cables & Peripherals',
      icon: '🔌',
      averageWeightKg: 0.6,
      baseValuationPerKg: 55.0,
      description: 'High-copper ethernet, power cables, adapters, mice, and keyboards.',
      sdgTarget: 'SDG 8',
    ),
  ];
}
