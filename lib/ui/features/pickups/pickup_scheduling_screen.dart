import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/collection_center_repository.dart';
import '../../../data/repositories/ewaste_repository.dart';
import '../../../data/repositories/pickup_repository.dart';
import '../../../domain/models/collection_center.dart';
import '../../../domain/models/ewaste_item.dart';
import '../../theme/app_theme.dart';
import 'pickup_tracking_screen.dart';

class PickupSchedulingScreen extends StatefulWidget {
  final CollectionCenter? preselectedCenter;

  const PickupSchedulingScreen({super.key, this.preselectedCenter});

  @override
  State<PickupSchedulingScreen> createState() => _PickupSchedulingScreenState();
}

class _PickupSchedulingScreenState extends State<PickupSchedulingScreen> {
  final AuthRepository _authRepo = AuthRepository();
  final EwasteRepository _ewasteRepo = EwasteRepository();
  final CollectionCenterRepository _centerRepo = CollectionCenterRepository();
  final PickupRepository _pickupRepo = PickupRepository();

  late CollectionCenter _selectedCenter;
  final Set<String> _selectedItemIds = {};
  late DateTime _selectedDate;
  String _selectedSlot = '10:00 AM - 01:00 PM';

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isDataWipedConfirmed = true;
  bool _isBatteryTapedConfirmed = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCenter = widget.preselectedCenter ?? _centerRepo.centers.first;
    _selectedDate = DateTime.now().add(const Duration(days: 1));

    final user = _authRepo.currentUser;
    _addressController.text =
        user?.defaultAddress ?? 'Flat 402, Green Meadows, Bengaluru, KA';
    _phoneController.text = user?.phoneNumber ?? '+91 98765 43210';

    if (_ewasteRepo.items.isNotEmpty) {
      _selectedItemIds.add(_ewasteRepo.items.first.id);
    }
  }

  void _confirmPickup() async {
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 device to collect.')),
      );
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide your collection address.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final selectedItems = _ewasteRepo.items
        .where((i) => _selectedItemIds.contains(i.id))
        .toList();

    int totalCredits = 0;
    double totalWeight = 0.0;
    final List<String> summaries = [];

    for (var i in selectedItems) {
      totalCredits += i.greenCreditsEarned;
      totalWeight += i.weightKg;
      summaries.add(i.title);
    }

    final newPickup = await _pickupRepo.schedulePickup(
      userId: _authRepo.currentUser?.id ?? 'demo_user_001',
      centerId: _selectedCenter.id,
      centerName: _selectedCenter.name,
      itemIds: _selectedItemIds.toList(),
      itemsSummary: summaries.join(', '),
      pickupAddress: _addressController.text.trim(),
      contactPhone: _phoneController.text.trim(),
      preferredDate: _selectedDate,
      preferredTimeSlot: _selectedSlot,
      estimatedCredits: totalCredits,
      estimatedWeight: totalWeight,
    );

    // Update statuses of items to scheduled
    for (var id in _selectedItemIds) {
      await _ewasteRepo.updateStatus(id, EwasteStatus.scheduled);
    }

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PickupTrackingScreen(pickup: newPickup),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableItems = _ewasteRepo.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Doorstep Pickup'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined,
                    color: AppTheme.primaryGreen, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Certified collection agents arrive with sealed antistatic containers. '
                    'All pickups include digital chain-of-custody tracking.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF166534),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. Select Items
          const Text(
            'SELECT ITEMS FOR PICKUP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 8),

          if (availableItems.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('No e-waste items in inventory yet.'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Evaluate a Device First'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...availableItems.map((item) {
              final isChecked = _selectedItemIds.contains(item.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isChecked ? AppTheme.accentMint : AppTheme.borderLight,
                    width: isChecked ? 2 : 1,
                  ),
                ),
                child: CheckboxListTile(
                  value: isChecked,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedItemIds.add(item.id);
                      } else {
                        _selectedItemIds.remove(item.id);
                      }
                    });
                  },
                  secondary: Text(item.category.icon,
                      style: const TextStyle(fontSize: 22)),
                  title: Text(item.title,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    'Valuation: \$${item.estimatedValue.toStringAsFixed(0)} • +${item.greenCreditsEarned} Credits',
                    style: const TextStyle(
                        fontSize: 11.5, color: AppTheme.textMutedLight),
                  ),
                ),
              );
            }),

          const SizedBox(height: 20),

          // 2. Select Certified Hub
          const Text(
            'ASSIGNED R2 RECYCLING FACILITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<CollectionCenter>(
            initialValue: _selectedCenter,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: _centerRepo.centers.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(
                  '${c.name.split(" - ").first} (${c.distanceKm} km)',
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCenter = val);
            },
          ),
          const SizedBox(height: 20),

          // 3. Date & Time Slot
          const Text(
            'DATE & TIME WINDOW',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedSlot,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '10:00 AM - 01:00 PM',
                      child: Text('10:00 AM - 01:00 PM',
                          style: TextStyle(fontSize: 11)),
                    ),
                    DropdownMenuItem(
                      value: '02:00 PM - 05:00 PM',
                      child: Text('02:00 PM - 05:00 PM',
                          style: TextStyle(fontSize: 11)),
                    ),
                    DropdownMenuItem(
                      value: '05:00 PM - 08:00 PM',
                      child: Text('05:00 PM - 08:00 PM',
                          style: TextStyle(fontSize: 11)),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSlot = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Pickup Address & Phone
          const Text(
            'CONTACT & PICKUP ADDRESS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Doorstep Address',
              prefixIcon: Icon(Icons.home_outlined),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Contact Phone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),

          // 5. Pre-Collection Verification Checklist
          const Text(
            'SAFETY & COMPLIANCE CONFIRMATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: _isDataWipedConfirmed,
            activeColor: AppTheme.primaryGreen,
            title: const Text(
              'I have backed up and factory-reset my devices',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            onChanged: (val) =>
                setState(() => _isDataWipedConfirmed = val ?? false),
          ),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: _isBatteryTapedConfirmed,
            activeColor: AppTheme.primaryGreen,
            title: const Text(
              'Loose batteries or exposed cables have insulated terminals',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            onChanged: (val) =>
                setState(() => _isBatteryTapedConfirmed = val ?? false),
          ),
          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppTheme.primaryGreen,
            ),
            onPressed: (_isSubmitting ||
                    !_isDataWipedConfirmed ||
                    !_isBatteryTapedConfirmed)
                ? null
                : _confirmPickup,
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Confirm Doorstep Collection',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
