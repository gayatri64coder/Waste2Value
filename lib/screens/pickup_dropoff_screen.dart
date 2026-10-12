import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart';
import '../providers/pickup_provider.dart';
import '../models/pickup_request_model.dart';
import '../models/collection_point_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class PickupDropoffScreen extends StatefulWidget {
  const PickupDropoffScreen({super.key});

  @override
  State<PickupDropoffScreen> createState() => _PickupDropoffScreenState();
}

class _PickupDropoffScreenState extends State<PickupDropoffScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DisposalType _disposalType = DisposalType.doorstepPickup;
  CollectionPoint? _selectedCenter;
  DateTime _preferredDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = '10:00 AM – 01:00 PM';
  bool _isSubmitting = false;

  static const List<String> _timeSlots = [
    '08:00 AM – 11:00 AM',
    '10:00 AM – 01:00 PM',
    '12:00 PM – 03:00 PM',
    '02:00 PM – 05:00 PM',
    '04:00 PM – 07:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _disposalType = _tabController.index == 0
            ? DisposalType.doorstepPickup
            : DisposalType.centerDropoff;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PickupProvider>().loadCollectionPoints();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  Future<void> _handleSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_disposalType == DisposalType.centerDropoff &&
        _selectedCenter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a collection center')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final user = context.read<AuthProvider>().currentUser;

    final request = PickupRequest(
      id: const Uuid().v4(),
      userId: user?.id ?? 'demo_user_001',
      disposalType: _disposalType,
      centerId: _selectedCenter?.id ?? 'point_001',
      centerName: _selectedCenter?.name ?? 'EcoCycler Central Hub',
      itemIds: [],
      itemsSummary: 'Selected e-waste items for circular disposal',
      pickupAddress: _disposalType == DisposalType.doorstepPickup
          ? _addressCtrl.text.trim()
          : (_selectedCenter?.address ?? ''),
      contactPhone: _phoneCtrl.text.trim(),
      preferredDate: _preferredDate,
      preferredTimeSlot: _selectedTimeSlot,
      status: PickupStatus.requested,
      estimatedGreenCredits: 80,
      estimatedWeightKg: 2.0,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      createdAt: DateTime.now(),
    );

    await context.read<PickupProvider>().schedulePickup(request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Pickup scheduled! You will be notified when an agent is assigned.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = context.watch<PickupProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Schedule Pickup / Drop-off'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primaryGreen,
          tabs: const [
            Tab(icon: Icon(Icons.local_shipping_outlined), text: 'Doorstep Pickup'),
            Tab(icon: Icon(Icons.location_on_outlined), text: 'Center Drop-off'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            // ── Doorstep Pickup Tab ──
            _buildPickupTab(),
            // ── Center Drop-off Tab ──
            _buildDropoffTab(pickup.centers),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _handleSchedule,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check_circle_outline_rounded),
          label:
              Text(_isSubmitting ? 'Scheduling...' : 'Confirm Schedule'),
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
      ),
    );
  }

  Widget _buildPickupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _InfoBanner(
            icon: '🚚',
            text: 'A certified eco-agent will collect from your address within the selected time window.',
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Pickup Address *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _addressCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Full address with flat/house number, area, city, PIN',
              prefixIcon: Icon(Icons.home_outlined),
            ),
            validator: (v) =>
                _disposalType == DisposalType.doorstepPickup &&
                        (v == null || v.trim().isEmpty)
                    ? 'Address required'
                    : null,
          ),
          const SizedBox(height: 16),
          ..._buildSharedFields(),
        ],
      ),
    );
  }

  Widget _buildDropoffTab(List<CollectionPoint> centers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _InfoBanner(
            icon: '📍',
            text: 'Book a slot at a certified R2/e-Stewards drop-off facility near you.',
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Select Collection Center *'),
          const SizedBox(height: 10),
          if (centers.isEmpty)
            const Center(child: CircularProgressIndicator(color: AppColors.accentMint))
          else
            ...centers.map((c) => _CenterTile(
                  center: c,
                  isSelected: _selectedCenter?.id == c.id,
                  onTap: () => setState(() => _selectedCenter = c),
                )),
          const SizedBox(height: 16),
          ..._buildSharedFields(),
        ],
      ),
    );
  }

  List<Widget> _buildSharedFields() {
    return [
      const _FieldLabel('Contact Phone *'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          hintText: '+91 98765 43210',
          prefixIcon: Icon(Icons.phone_outlined),
        ),
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Phone number required' : null,
      ),
      const SizedBox(height: 16),
      const _FieldLabel('Preferred Date *'),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: _pickDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: AppColors.textMuted, size: 20),
              const SizedBox(width: 12),
              Text(Formatters.formatDate(_preferredDate),
                  style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
              const Spacer(),
              const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      const _FieldLabel('Preferred Time Slot *'),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _timeSlots.map((slot) {
          final isSel = _selectedTimeSlot == slot;
          return GestureDetector(
            onTap: () => setState(() => _selectedTimeSlot = slot),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSel
                    ? AppColors.primaryGreen.withAlpha(15)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSel ? AppColors.primaryGreen : AppColors.borderLight,
                  width: isSel ? 2 : 1,
                ),
              ),
              child: Text(slot,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSel
                          ? AppColors.primaryGreen
                          : AppColors.textMuted)),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 16),
      const _FieldLabel('Additional Notes (Optional)'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _notesCtrl,
        maxLines: 2,
        decoration: const InputDecoration(
            hintText: 'Gate code, special handling instructions, etc.'),
      ),
      const SizedBox(height: 80),
    ];
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark));
  }
}

class _InfoBanner extends StatelessWidget {
  final String icon;
  final String text;
  const _InfoBanner({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }
}

class _CenterTile extends StatelessWidget {
  final CollectionPoint center;
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterTile({
    required this.center,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withAlpha(15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(center.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.textDark)),
                  const SizedBox(height: 3),
                  Text(center.address,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (center.isCertifiedR2)
                        _Badge('R2v3', AppColors.primaryGreen),
                      if (center.isCertifiedEStewards) ...[
                        const SizedBox(width: 6),
                        _Badge('e-Stewards', AppColors.accentMint),
                      ],
                      const SizedBox(width: 6),
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.amberGold),
                      Text('${center.rating}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.amberGold)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text('${center.distanceKm?.toStringAsFixed(1) ?? "?"} km',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen)),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primaryGreen, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
