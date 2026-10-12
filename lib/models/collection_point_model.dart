/// CollectionPoint model for authorized e-waste drop-off and certified recycling facilities
class CollectionPoint {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String operatingHours;
  final List<String> acceptedCategoryIds;
  final bool isCertifiedR2;
  final bool isCertifiedEStewards;
  final double rating;
  final double? distanceKm;
  final String dropOffGuidelines;
  final bool acceptsHazardousBatteries;

  const CollectionPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.operatingHours,
    required this.acceptedCategoryIds,
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
      'acceptedCategoryIds': acceptedCategoryIds,
      'isCertifiedR2': isCertifiedR2,
      'isCertifiedEStewards': isCertifiedEStewards,
      'rating': rating,
      'distanceKm': distanceKm,
      'dropOffGuidelines': dropOffGuidelines,
      'acceptsHazardousBatteries': acceptsHazardousBatteries,
    };
  }

  factory CollectionPoint.fromMap(Map<String, dynamic> map, String id) {
    return CollectionPoint(
      id: id,
      name: map['name'] as String? ?? 'E-Waste Drop Hub',
      address: map['address'] as String? ?? 'Green Tech Avenue',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 12.9716,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 77.5946,
      phone: map['phone'] as String? ?? '+91 80 2345 6789',
      email: map['email'] as String? ?? 'recycle@ecohub.org',
      operatingHours: map['operatingHours'] as String? ?? 'Mon-Sat: 09:00 AM - 06:00 PM',
      acceptedCategoryIds: (map['acceptedCategoryIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isCertifiedR2: map['isCertifiedR2'] as bool? ?? true,
      isCertifiedEStewards: map['isCertifiedEStewards'] as bool? ?? true,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 2.5,
      dropOffGuidelines: map['dropOffGuidelines'] as String? ?? 'Please perform data sanitization before drop-off.',
      acceptsHazardousBatteries: map['acceptsHazardousBatteries'] as bool? ?? true,
    );
  }

  static const List<CollectionPoint> defaultPoints = [
    CollectionPoint(
      id: 'point_001',
      name: 'EcoCycler Central Hub (R2v3 Certified)',
      address: 'Plot 42, Electronic City Phase 1, Bangalore',
      latitude: 12.8452,
      longitude: 77.6602,
      phone: '+91 80 2852 1100',
      email: 'ecocity@waste2value.org',
      operatingHours: 'Mon - Sat: 08:30 AM - 07:00 PM',
      acceptedCategoryIds: ['cat_smartphones', 'cat_laptops', 'cat_pcbs', 'cat_batteries'],
      isCertifiedR2: true,
      isCertifiedEStewards: true,
      rating: 4.9,
      distanceKm: 2.1,
      dropOffGuidelines: 'Certified secure data sanitization available on-site. Free antistatic packing provided.',
      acceptsHazardousBatteries: true,
    ),
    CollectionPoint(
      id: 'point_002',
      name: 'GreenMetals Recovery Kiosk',
      address: 'Indiranagar 100ft Road, Near Metro Pillar 140',
      latitude: 12.9784,
      longitude: 77.6408,
      phone: '+91 80 4123 7788',
      email: 'indiranagar@greenmetals.in',
      operatingHours: 'Mon - Sun: 10:00 AM - 08:30 PM',
      acceptedCategoryIds: ['cat_smartphones', 'cat_laptops', 'cat_cables', 'cat_batteries'],
      isCertifiedR2: true,
      isCertifiedEStewards: false,
      rating: 4.7,
      distanceKm: 4.8,
      dropOffGuidelines: 'Instant weigh-and-credit scanner kiosk with QR barcode verification.',
      acceptsHazardousBatteries: true,
    ),
    CollectionPoint(
      id: 'point_003',
      name: 'Urban Smelt Circular Economy Depot',
      address: 'Peenya Industrial Area, 4th Cross Road',
      latitude: 13.0285,
      longitude: 77.5195,
      phone: '+91 80 2839 9000',
      email: 'peenya@urbansmelt.org',
      operatingHours: 'Mon - Fri: 09:00 AM - 06:00 PM',
      acceptedCategoryIds: ['cat_displays', 'cat_appliances', 'cat_pcbs', 'cat_laptops'],
      isCertifiedR2: true,
      isCertifiedEStewards: true,
      rating: 4.8,
      distanceKm: 8.6,
      dropOffGuidelines: 'Heavy electronics, server racks, and CRT/OLED display safe disposal.',
      acceptsHazardousBatteries: false,
    ),
  ];
}
