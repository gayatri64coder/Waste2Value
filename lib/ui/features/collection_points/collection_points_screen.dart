import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/config/environment_config.dart';
import '../../../data/repositories/collection_center_repository.dart';
import '../../../domain/models/collection_center.dart';
import '../../../domain/models/ewaste_item.dart';
import '../../theme/app_theme.dart';
import '../pickups/pickup_scheduling_screen.dart';

class CollectionPointsScreen extends StatefulWidget {
  const CollectionPointsScreen({super.key});

  @override
  State<CollectionPointsScreen> createState() => _CollectionPointsScreenState();
}

class _CollectionPointsScreenState extends State<CollectionPointsScreen> {
  final CollectionCenterRepository _repo = CollectionCenterRepository();
  final TextEditingController _searchController = TextEditingController();

  DeviceCategory? _selectedCategoryFilter;
  bool _onlyCertifiedR2 = false;
  bool _isMapView = false;

  GoogleMapController? _mapController;
  CollectionCenter? _selectedCenter;

  static const LatLng _initialPosition = LatLng(12.9716, 77.5946); // Bengaluru default center

  List<CollectionCenter> get _filteredCenters => _repo.searchCenters(
        query: _searchController.text,
        filterCategory: _selectedCategoryFilter,
        onlyCertifiedR2: _onlyCertifiedR2,
      );

  Set<Marker> _buildMarkers(List<CollectionCenter> centers) {
    return centers.map((c) {
      return Marker(
        markerId: MarkerId(c.id),
        position: LatLng(c.latitude, c.longitude),
        infoWindow: InfoWindow(
          title: c.name,
          snippet: '${c.distanceKm ?? 2.5} km • ${c.operatingHours}',
        ),
        onTap: () {
          setState(() {
            _selectedCenter = c;
          });
        },
      );
    }).toSet();
  }

  void _showCenterDetails(CollectionCenter center) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          center.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          center.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: [
                  if (center.isCertifiedR2)
                    _buildBadge('R2v3 Certified', AppTheme.primaryGreen),
                  if (center.isCertifiedEStewards)
                    _buildBadge('e-Stewards', const Color(0xFF0284C7)),
                  if (center.acceptsHazardousBatteries)
                    _buildBadge('Lithium Safe', const Color(0xFFD97706)),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow(Icons.access_time_rounded, 'Hours:', center.operatingHours),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.phone_outlined, 'Contact:', center.phone),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.email_outlined, 'Email:', center.email),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.info_outline, 'Guidelines:', center.dropOffGuidelines),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.directions_outlined),
                      label: const Text('Directions'),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Navigating to ${center.name} (${center.distanceKm} km)'),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: const Text('Schedule Drop-Off'),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PickupSchedulingScreen(
                              preselectedCenter: center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.textMutedLight),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final centers = _filteredCenters;
    final isMapsConfigured = EnvironmentConfig.isGoogleMapsConfigured;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certified Drop-Off Hubs'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list_rounded : Icons.map_rounded),
            tooltip: _isMapView ? 'Switch to List' : 'Switch to Map',
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // If Maps API Key is the placeholder, render clear development notice
          if (!isMapsConfigured) _buildMapsDevelopmentBanner(),

          // Search and Filters Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search center name or area...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('R2 Certified Only'),
                  selected: _onlyCertifiedR2,
                  onSelected: (val) {
                    setState(() {
                      _onlyCertifiedR2 = val;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...[
                  DeviceCategory.battery,
                  DeviceCategory.smartphone,
                  DeviceCategory.laptop,
                  DeviceCategory.circuitBoard,
                ].map((cat) {
                  final isSel = _selectedCategoryFilter == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${cat.icon} ${cat.label.split('/').first}'),
                      selected: isSel,
                      onSelected: (val) {
                        setState(() {
                          _selectedCategoryFilter = val ? cat : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Main View: Either Map View or List Explorer
          Expanded(
            child: _isMapView
                ? _buildMapView(centers, isMapsConfigured)
                : _buildListView(centers),
          ),
        ],
      ),
    );
  }

  Widget _buildMapsDevelopmentBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFEF3C7),
        border: Border(
          bottom: BorderSide(color: Color(0xFFF59E0B), width: 1),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.map_outlined, color: Color(0xFFB45309), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Google Maps Key: YOUR_GOOGLE_MAPS_API_KEY placeholder detected. '
              'The app runs in offline center discovery mode. '
              'Provide MAPS_API_KEY in local.properties or .env to activate live satellite map rendering.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(List<CollectionCenter> centers, bool isMapsConfigured) {
    // If running on non-mobile (web without key or desktop) or key is pending:
    // Render the interactive Radar & Visual Canvas fallback
    if (!isMapsConfigured || kIsWeb) {
      return _buildInteractiveRadarView(centers);
    }

    // Real GoogleMap widget (runs smoothly when key is provided on Android/iOS)
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _initialPosition,
            zoom: 12.0,
          ),
          markers: _buildMarkers(centers),
          onMapCreated: (controller) => _mapController = controller,
          myLocationEnabled: false,
          zoomControlsEnabled: true,
        ),
        Positioned(
          right: 16,
          top: 16,
          child: FloatingActionButton.small(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryGreen,
            child: const Icon(Icons.my_location),
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(_initialPosition, 12.0),
              );
            },
          ),
        ),
        if (_selectedCenter != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCenter!.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _selectedCenter!.address,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textMutedLight),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                      onPressed: () => _showCenterDetails(_selectedCenter!),
                      child: const Text('View Center Details'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInteractiveRadarView(List<CollectionCenter> centers) {
    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1E293B),
            child: const Row(
              children: [
                Icon(Icons.radar, color: AppTheme.accentMint, size: 20),
                SizedBox(width: 8),
                Text(
                  'Interactive Collection Hub Radar (Offline Mode)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Range rings
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accentMint.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accentMint.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentMint.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppTheme.accentMint,
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Text('📍 You',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),

                  // Pins around the radar
                  ...centers.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final c = entry.value;
                    // Spread coordinates symmetrically for visualization
                    final double angle = (idx * (2 * pi / (centers.isEmpty ? 1 : centers.length)));
                    final double radius = 70.0 + (idx * 20.0).clamp(0, 45);
                    final double x = radius * cos(angle);
                    final double y = radius * sin(angle);

                    return Transform.translate(
                      offset: Offset(x, y),
                      child: InkWell(
                        onTap: () => _showCenterDetails(c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.accentMint, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.accentMint, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${c.name.split(" ").first} (${c.distanceKm}km)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1E293B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tap any radar station to inspect operating hours & book drop-off',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<CollectionCenter> centers) {
    if (centers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_outlined,
                size: 48, color: AppTheme.textMutedLight),
            const SizedBox(height: 12),
            const Text(
              'No certified centers matching your filters',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedCategoryFilter = null;
                  _onlyCertifiedR2 = false;
                });
              },
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: centers.length,
      itemBuilder: (context, index) {
        final center = centers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.domain,
                            color: Color(0xFF0284C7), size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            center.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            center.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.lightMint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${center.distanceKm ?? 2.5} km',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: [
                    if (center.isCertifiedR2)
                      _buildBadge('R2v3 Certified', AppTheme.primaryGreen),
                    if (center.isCertifiedEStewards)
                      _buildBadge('e-Stewards', const Color(0xFF0284C7)),
                    if (center.acceptsHazardousBatteries)
                      _buildBadge('Battery Safe', const Color(0xFFD97706)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '🕒 ${center.operatingHours}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF475569),
                  ),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Details'),
                      onPressed: () => _showCenterDetails(center),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('Book Drop-Off'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PickupSchedulingScreen(
                              preselectedCenter: center,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
