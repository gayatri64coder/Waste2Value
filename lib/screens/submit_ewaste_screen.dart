import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart';
import '../providers/ewaste_provider.dart';
import '../providers/rewards_provider.dart';
import '../models/ewaste_item_model.dart';
import '../models/category_model.dart';
import '../theme/app_colors.dart';

class SubmitEWasteScreen extends StatefulWidget {
  const SubmitEWasteScreen({super.key});

  @override
  State<SubmitEWasteScreen> createState() => _SubmitEWasteScreenState();
}

class _SubmitEWasteScreenState extends State<SubmitEWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Category? _selectedCategory;
  DeviceCondition _condition = DeviceCondition.good;
  FunctionalStatus _functional = FunctionalStatus.working;
  int _purchaseYear = DateTime.now().year - 3;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _serialCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double _computeValue() {
    if (_selectedCategory == null) return 0;
    final base = _selectedCategory!.baseValuationPerKg *
        _selectedCategory!.averageWeightKg;
    final age = (DateTime.now().year - _purchaseYear).clamp(0, 10);
    final ageFactor = 1.0 - (age * 0.07).clamp(0, 0.65);
    return base * _condition.valuationMultiplier * _functional.multiplier * ageFactor;
  }

  int _computeCredits() => (_computeValue() * 2).round();

  double _computeCo2() {
    if (_selectedCategory == null) return 0;
    return _selectedCategory!.averageWeightKg * 2.45;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a device category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final userId = context.read<AuthProvider>().currentUser?.id ?? 'demo_user';

    final metals = _estimateMetals(_selectedCategory!.id);
    final item = EWasteItem(
      id: const Uuid().v4(),
      userId: userId,
      title: '${_brandCtrl.text.trim()} ${_modelCtrl.text.trim()}',
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      purchaseYear: _purchaseYear,
      condition: _condition,
      functionalStatus: _functional,
      estimatedValue: _computeValue(),
      carbonSavedKg: _computeCo2(),
      weightKg: _selectedCategory!.averageWeightKg,
      preciousMetals: metals,
      greenCreditsEarned: _computeCredits(),
      status: EwasteStatus.submitted,
      recommendedAction: _getRecommendation(),
      serialNumber: _serialCtrl.text.trim().isNotEmpty
          ? _serialCtrl.text.trim()
          : null,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      createdAt: DateTime.now(),
    );

    await context.read<EWasteProvider>().addItem(item);
    await context.read<RewardsProvider>().earnPoints(
          userId: userId,
          activityTitle: '${item.brand} ${item.model} submitted',
          points: item.greenCreditsEarned,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '✅ ${item.title} submitted! +${item.greenCreditsEarned} credits earned.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  PreciousMetalsEstimate _estimateMetals(String categoryId) {
    final multipliers = {
      'cat_pcbs': (0.22, 1.10, 310.0, 0.04),
      'cat_laptops': (0.18, 1.20, 420.0, 0.05),
      'cat_smartphones': (0.034, 0.35, 15.0, 0.015),
      'cat_batteries': (0.001, 0.05, 8.0, 0.002),
    };
    final m = multipliers[categoryId] ?? (0.02, 0.25, 20.0, 0.01);
    return PreciousMetalsEstimate(
      goldGrams: m.$1,
      silverGrams: m.$2,
      copperGrams: m.$3,
      palladiumGrams: m.$4,
    );
  }

  String _getRecommendation() {
    if (_functional == FunctionalStatus.working &&
        (_condition == DeviceCondition.flawless ||
            _condition == DeviceCondition.good)) {
      return 'Refurbish & Reuse — High residual life detected';
    }
    if (_functional == FunctionalStatus.hazardousBattery) {
      return '⚠️ Safe Hazardous Battery Disposal — Mandatory Protocol';
    }
    if (_condition == DeviceCondition.brokenOrDamaged ||
        _functional == FunctionalStatus.dead) {
      return 'Certified Precious Metals Recovery';
    }
    return 'Component Harvesting — Selective Parts Recovery';
  }

  @override
  Widget build(BuildContext context) {
    final estimatedValue = _computeValue();
    final credits = _computeCredits();
    final co2 = _computeCo2();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Submit E-Waste'),
        backgroundColor: AppColors.surfaceLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live valuation preview
                    if (_selectedCategory != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F5132), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ValuationStat(
                                label: 'Est. Value',
                                value:
                                    '\$${estimatedValue.toStringAsFixed(0)}',
                                icon: '💰'),
                            _ValuationStat(
                                label: 'Green Credits',
                                value: '+$credits',
                                icon: '🌱'),
                            _ValuationStat(
                                label: 'CO₂ Saved',
                                value: '${co2.toStringAsFixed(1)} kg',
                                icon: '🌍'),
                          ],
                        ),
                      ),

                    // Category selection
                    const _FormLabel('Device Category *'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: Category.defaultCategories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, idx) {
                          final cat = Category.defaultCategories[idx];
                          final isSelected = _selectedCategory?.id == cat.id;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 90,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryGreen.withAlpha(15)
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : AppColors.borderLight,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(cat.icon,
                                      style: const TextStyle(fontSize: 28)),
                                  const SizedBox(height: 6),
                                  Text(cat.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.primaryGreen
                                              : AppColors.textMuted),
                                      maxLines: 2),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Brand & Model
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FormLabel('Brand *'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _brandCtrl,
                                decoration: const InputDecoration(
                                    hintText: 'e.g. Apple, Samsung'),
                                onChanged: (_) => setState(() {}),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FormLabel('Model *'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _modelCtrl,
                                decoration: const InputDecoration(
                                    hintText: 'e.g. iPhone 12, Galaxy S20'),
                                onChanged: (_) => setState(() {}),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Purchase Year
                    const _FormLabel('Purchase Year'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: _purchaseYear,
                      decoration: const InputDecoration(hintText: 'Select year'),
                      items: List.generate(15, (i) => DateTime.now().year - i)
                          .map((y) => DropdownMenuItem(
                              value: y, child: Text(y.toString())))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _purchaseYear = v ?? _purchaseYear),
                    ),
                    const SizedBox(height: 20),

                    // Condition
                    const _FormLabel('Physical Condition *'),
                    const SizedBox(height: 10),
                    ...DeviceCondition.values.map(
                      (c) => _ConditionTile(
                        label: c.label,
                        isSelected: _condition == c,
                        onTap: () => setState(() => _condition = c),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Functional Status
                    const _FormLabel('Functional Status *'),
                    const SizedBox(height: 10),
                    ...FunctionalStatus.values.map(
                      (f) => _ConditionTile(
                        label: f.label,
                        isSelected: _functional == f,
                        onTap: () => setState(() => _functional = f),
                        isHazardous: f == FunctionalStatus.hazardousBattery,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Optional fields
                    const _FormLabel('Serial / IMEI (Optional)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _serialCtrl,
                      decoration: const InputDecoration(
                          hintText: 'For chain-of-custody passport'),
                    ),
                    const SizedBox(height: 16),
                    const _FormLabel('Additional Notes (Optional)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          hintText: 'Known issues, accessories included, etc.'),
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: Text(_isSubmitting
                            ? 'Submitting...'
                            : 'Submit & Earn Credits'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark));
  }
}

class _ValuationStat extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _ValuationStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withAlpha(180), fontSize: 11)),
      ],
    );
  }
}

class _ConditionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isHazardous;

  const _ConditionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isHazardous = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHazardous ? AppColors.alertRed : AppColors.primaryGreen;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(15) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (isHazardous)
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.alertRed, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? color : AppColors.textDark)),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
