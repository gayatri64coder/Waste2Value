import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../domain/models/collection_center.dart';
import '../../domain/models/ewaste_item.dart';

/// Repository for certified e-waste drop-off stations and recycling hubs.
class CollectionCenterRepository extends ChangeNotifier {
  static final CollectionCenterRepository _instance =
      CollectionCenterRepository._internal();
  factory CollectionCenterRepository() => _instance;
  CollectionCenterRepository._internal() {
    _initCenters();
  }

  final List<CollectionCenter> _centers = [];
  List<CollectionCenter> get centers => List.unmodifiable(_centers);

  void _initCenters() {
    _centers.addAll([
      const CollectionCenter(
        id: 'center_001',
        name: 'EcoCycler Certified R2 Hub - Whitefield',
        address: 'Plot 48, Export Promotion Industrial Park, Whitefield, Bengaluru',
        latitude: 12.9784,
        longitude: 77.7289,
        phone: '+91 80 4123 4567',
        email: 'whitefield@ecocycler.in',
        operatingHours: 'Mon - Sat: 08:30 AM - 07:00 PM',
        acceptedCategories: [
          DeviceCategory.smartphone,
          DeviceCategory.laptop,
          DeviceCategory.tablet,
          DeviceCategory.desktop,
          DeviceCategory.monitor,
          DeviceCategory.circuitBoard,
          DeviceCategory.battery,
          DeviceCategory.homeAppliance,
          DeviceCategory.cablesAndPeripherals,
        ],
        isCertifiedR2: true,
        isCertifiedEStewards: true,
        rating: 4.9,
        distanceKm: 2.3,
        dropOffGuidelines:
            'Free instant weighing & green voucher issuance. Dedicated fire-safe lithium storage bins available.',
        acceptsHazardousBatteries: true,
      ),
      const CollectionCenter(
        id: 'center_002',
        name: 'GreenShield Electronic Recycling & ITAD',
        address: 'Sy No. 24, Outer Ring Road, Bellandur, Bengaluru',
        latitude: 12.9304,
        longitude: 77.6784,
        phone: '+91 80 2567 8901',
        email: 'operations@greenshielditad.com',
        operatingHours: 'Mon - Fri: 09:00 AM - 06:00 PM',
        acceptedCategories: [
          DeviceCategory.laptop,
          DeviceCategory.desktop,
          DeviceCategory.monitor,
          DeviceCategory.circuitBoard,
          DeviceCategory.smartphone,
        ],
        isCertifiedR2: true,
        isCertifiedEStewards: false,
        rating: 4.7,
        distanceKm: 4.8,
        dropOffGuidelines:
            'Specializes in enterprise asset disposition. DoD 5220.22-M magnetic degaussing certificates provided on-site.',
        acceptsHazardousBatteries: false,
      ),
      const CollectionCenter(
        id: 'center_003',
        name: 'Circular Planet Community E-Drop Station',
        address: '12th Main, 100ft Road, Indiranagar, Bengaluru',
        latitude: 12.9719,
        longitude: 77.6412,
        phone: '+91 80 6789 0123',
        email: 'indiranagar@circularplanet.org',
        operatingHours: 'All Days: 10:00 AM - 08:30 PM',
        acceptedCategories: [
          DeviceCategory.smartphone,
          DeviceCategory.tablet,
          DeviceCategory.battery,
          DeviceCategory.cablesAndPeripherals,
          DeviceCategory.homeAppliance,
        ],
        isCertifiedR2: true,
        isCertifiedEStewards: true,
        rating: 4.8,
        distanceKm: 6.1,
        dropOffGuidelines:
            'Convenient drive-through kiosk. Instant mobile app QR scan credit deposit upon drop-off.',
        acceptsHazardousBatteries: true,
      ),
      const CollectionCenter(
        id: 'center_004',
        name: 'Apex Metal Smelting & Circular Minerals',
        address: 'Industrial Area Phase 2, Peenya, Bengaluru',
        latitude: 13.0298,
        longitude: 77.5186,
        phone: '+91 80 8901 2345',
        email: 'peenya@apexsmelting.com',
        operatingHours: 'Mon - Sat: 08:00 AM - 05:00 PM',
        acceptedCategories: [
          DeviceCategory.desktop,
          DeviceCategory.circuitBoard,
          DeviceCategory.monitor,
          DeviceCategory.homeAppliance,
          DeviceCategory.cablesAndPeripherals,
        ],
        isCertifiedR2: true,
        isCertifiedEStewards: true,
        rating: 4.6,
        distanceKm: 12.4,
        dropOffGuidelines:
            'High-capacity facility handling bulk and industrial loads. Direct bulk scrap weighing bridge.',
        acceptsHazardousBatteries: true,
      ),
    ]);
  }

  /// Filter centers by accepted category and search keyword
  List<CollectionCenter> searchCenters({
    String? query,
    DeviceCategory? filterCategory,
    bool onlyCertifiedR2 = false,
  }) {
    return _centers.where((c) {
      if (onlyCertifiedR2 && !c.isCertifiedR2) return false;
      if (filterCategory != null &&
          !c.acceptedCategories.contains(filterCategory)) {
        return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        final matchesName = c.name.toLowerCase().contains(q);
        final matchesAddress = c.address.toLowerCase().contains(q);
        return matchesName || matchesAddress;
      }
      return true;
    }).toList();
  }

  /// Finds the closest center from a given coordinate using Haversine formula
  CollectionCenter? findClosestCenter(double userLat, double userLng) {
    if (_centers.isEmpty) return null;
    CollectionCenter? nearest;
    double minDistance = double.infinity;

    for (final c in _centers) {
      final d = _calculateDistance(userLat, userLng, c.latitude, c.longitude);
      if (d < minDistance) {
        minDistance = d;
        nearest = c;
      }
    }
    return nearest;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
