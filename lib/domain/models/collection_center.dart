import 'ewaste_item.dart';

class CollectionCenter {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String operatingHours;
  final List<DeviceCategory> acceptedCategories;
  final bool isCertifiedR2;
  final bool isCertifiedEStewards;
  final double rating;
  final double? distanceKm;
  final String dropOffGuidelines;
  final bool acceptsHazardousBatteries;

  const CollectionCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.operatingHours,
    required this.acceptedCategories,
    required this.isCertifiedR2,
    required this.isCertifiedEStewards,
    this.rating = 4.8,
    this.distanceKm,
    required this.dropOffGuidelines,
    this.acceptsHazardousBatteries = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'operatingHours': operatingHours,
      'acceptedCategories': acceptedCategories.map((e) => e.name).toList(),
      'isCertifiedR2': isCertifiedR2,
      'isCertifiedEStewards': isCertifiedEStewards,
      'rating': rating,
      'distanceKm': distanceKm,
      'dropOffGuidelines': dropOffGuidelines,
      'acceptsHazardousBatteries': acceptsHazardousBatteries,
    };
  }

  factory CollectionCenter.fromMap(Map<String, dynamic> map, String id) {
    final categoriesList = (map['acceptedCategories'] as List<dynamic>?)
            ?.map((e) => DeviceCategory.fromString(e.toString()))
            .toList() ??
        DeviceCategory.values;

    return CollectionCenter(
      id: id,
      name: map['name'] as String? ?? 'E-Waste Hub',
      address: map['address'] as String? ?? 'Industrial Green Park',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 12.9716,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 77.5946,
      phone: map['phone'] as String? ?? '+91 80 2345 6789',
      email: map['email'] as String? ?? 'contact@ecohub.org',
      operatingHours:
          map['operatingHours'] as String? ?? 'Mon-Sat: 09:00 AM - 06:00 PM',
      acceptedCategories: categoriesList,
      isCertifiedR2: map['isCertifiedR2'] as bool? ?? true,
      isCertifiedEStewards: map['isCertifiedEStewards'] as bool? ?? true,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 2.4,
      dropOffGuidelines: map['dropOffGuidelines'] as String? ??
          'Please ensure data wiping is performed. Damaged batteries must be stored in antistatic pouches.',
      acceptsHazardousBatteries:
          map['acceptsHazardousBatteries'] as bool? ?? true,
    );
  }
}
