import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/ewaste_repository.dart';
import '../../../domain/ai/device_inspection_classifier.dart';
import '../../../domain/ai/ewaste_valuation_engine.dart';
import '../../../domain/models/ewaste_item.dart';
import '../../theme/app_theme.dart';

class ValuationCalculatorScreen extends StatefulWidget {
  final VoidCallback? onListedSuccessfully;

  const ValuationCalculatorScreen({super.key, this.onListedSuccessfully});

  @override
  State<ValuationCalculatorScreen> createState() =>
      _ValuationCalculatorScreenState();
}

class _ValuationCalculatorScreenState extends State<ValuationCalculatorScreen> {
  DeviceCategory _selectedCategory = DeviceCategory.smartphone;
  String _brand = 'Apple';
  final String _model = 'iPhone 13';
  int _purchaseYear = 2021;
  DeviceCondition _condition = DeviceCondition.good;
  FunctionalStatus _functionalStatus = FunctionalStatus.working;
  final TextEditingController _notesController = TextEditingController();

  // Diagnostic checklist states
  final Map<String, bool> _inspectionChecks = {
    'powers_on': true,
    'screen_intact': true,
    'battery_flat': true,
    'ports_working': true,
    'data_wiped': true,
  };
  bool _hasSwollenBattery = false;

  late ValuationResult _valuation;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _valuation = EwasteValuationEngine.evaluate(
        category: _selectedCategory,
        brand: _brand,
        purchaseYear: _purchaseYear,
        condition: _condition,
        functionalStatus: _functionalStatus,
        additionalNotes: _notesController.text,
      );
    });
  }

  void _showInspectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final report = DeviceInspectionClassifier.evaluateChecks(
              checkResults: _inspectionChecks,
              hasSwollenBatteryReported: _hasSwollenBattery,
            );

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 18,
                right: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Device Diagnostic Checklist',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Text(
                    'Local rule-based heuristic inspection scores device health.',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textMutedLight),
                  ),
                  const SizedBox(height: 14),

                  // Health score bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.speed,
                            color: AppTheme.primaryGreen, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Health Score: ${report.confidenceScore}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                report.safetyAdvisory,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _hasSwollenBattery
                                      ? Colors.red.shade700
                                      : const Color(0xFF475569),
                                  fontWeight: _hasSwollenBattery
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Checklist items
                  ...DeviceInspectionClassifier.standardChecklist.map((c) {
                    final isChecked = _inspectionChecks[c.id] ?? false;
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(c.label,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(c.description,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textMutedLight)),
                      value: isChecked,
                      activeColor: AppTheme.primaryGreen,
                      onChanged: (val) {
                        setModalState(() {
                          _inspectionChecks[c.id] = val ?? false;
                        });
                        setState(() {
                          _condition = report.determinedCondition;
                          _functionalStatus = report.determinedFunctionalStatus;
                          _recalculate();
                        });
                      },
                    );
                  }),

                  // Swollen battery trigger
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      '⚠️ Battery Bulge / Swelling Observed',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.red),
                    ),
                    value: _hasSwollenBattery,
                    activeThumbColor: Colors.red,
                    onChanged: (val) {
                      setModalState(() {
                        _hasSwollenBattery = val;
                      });
                      setState(() {
                        _condition = report.determinedCondition;
                        _functionalStatus = report.determinedFunctionalStatus;
                        _recalculate();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _recalculate();
                    },
                    child: const Text('Apply Inspection Diagnostics'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _listDevice() async {
    final authRepo = AuthRepository();
    final ewasteRepo = EwasteRepository();

    final newItem = EwasteItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      userId: authRepo.currentUser?.id ?? 'demo_user_001',
      title: '$_brand $_model ($_purchaseYear)',
      category: _selectedCategory,
      brand: _brand,
      model: _model,
      purchaseYear: _purchaseYear,
      condition: _condition,
      functionalStatus: _functionalStatus,
      estimatedValue: _valuation.estimatedValue,
      carbonSavedKg: _valuation.carbonSavedKg,
      weightKg: _valuation.weightKg,
      preciousMetals: _valuation.preciousMetals,
      greenCreditsEarned: _valuation.greenCredits,
      status: EwasteStatus.listed,
      recommendedAction: _valuation.primaryRecommendation,
      createdAt: DateTime.now(),
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    await ewasteRepo.addItem(newItem);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ Device listed! Valuation: \$${_valuation.estimatedValue.toStringAsFixed(0)} (+${_valuation.greenCredits} Credits)',
        ),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );

    widget.onListedSuccessfully?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valuation & Eco-Appraisal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dynamic Appraisal Output Card
          _buildAppraisalResultCard(),
          const SizedBox(height: 20),

          // Action Recommendation Alert
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _valuation.requiresHazardousHandling
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _valuation.requiresHazardousHandling
                    ? const Color(0xFFFECACA)
                    : const Color(0xFFBBF7D0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _valuation.requiresHazardousHandling
                          ? Icons.warning_amber_rounded
                          : Icons.eco_rounded,
                      color: _valuation.requiresHazardousHandling
                          ? Colors.red
                          : AppTheme.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _valuation.primaryRecommendation,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _valuation.requiresHazardousHandling
                              ? Colors.red.shade900
                              : const Color(0xFF14532D),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_valuation.actionableInsights.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._valuation.actionableInsights.map(
                    (insight) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '• $insight',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: _valuation.requiresHazardousHandling
                              ? Colors.red.shade800
                              : const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Diagnostic inspection button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Run Device Diagnostic Checklist'),
            onPressed: _showInspectionModal,
          ),
          const SizedBox(height: 20),

          const Text(
            'DEVICE SPECIFICATIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 10),

          // Category Chips
          const Text('Category',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: DeviceCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${cat.icon} ${cat.label}'),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedCategory = cat;
                          _recalculate();
                        });
                      }
                    },
                    selectedColor: AppTheme.lightMint,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : AppTheme.textLight,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Brand & Model
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Brand',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _brand,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Apple', child: Text('Apple')),
                        DropdownMenuItem(
                            value: 'Samsung', child: Text('Samsung')),
                        DropdownMenuItem(
                            value: 'Dell', child: Text('Dell')),
                        DropdownMenuItem(value: 'HP', child: Text('HP')),
                        DropdownMenuItem(
                            value: 'Lenovo', child: Text('Lenovo')),
                        DropdownMenuItem(
                            value: 'Sony', child: Text('Sony')),
                        DropdownMenuItem(
                            value: 'Generic', child: Text('Other / Generic')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _brand = val;
                            _recalculate();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vintage Year',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: _purchaseYear,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: List.generate(
                        10,
                        (index) {
                          final yr = DateTime.now().year - index;
                          return DropdownMenuItem(
                              value: yr, child: Text(yr.toString()));
                        },
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _purchaseYear = val;
                            _recalculate();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Physical Condition
          const Text('Physical Condition',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<DeviceCondition>(
            initialValue: _condition,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: DeviceCondition.values.map((cond) {
              return DropdownMenuItem(
                value: cond,
                child: Text(cond.label, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _condition = val;
                  _recalculate();
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Operational Status
          const Text('Operational Status',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<FunctionalStatus>(
            initialValue: _functionalStatus,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: FunctionalStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.label, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _functionalStatus = val;
                  _recalculate();
                });
              }
            },
          ),
          const SizedBox(height: 24),

          // Submit button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppTheme.primaryGreen,
            ),
            icon: const Icon(Icons.add_task_rounded),
            label: Text(
              'List Item for Recycling (\$${_valuation.estimatedValue.toStringAsFixed(0)})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            onPressed: _listDevice,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAppraisalResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VALUATION APPRAISAL',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Text(
                  '${_valuation.recyclabilityScore}% Recyclable',
                  style: const TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${_valuation.estimatedValue.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'USD credit value',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${_valuation.greenCredits} Credits',
                  style: const TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 14),

          // Urban mining precious metals breakdown
          const Text(
            'URBAN MINING RECOVERY ESTIMATE',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetalStat(
                  metal: 'Gold (Au)',
                  amount:
                      '${(_valuation.preciousMetals.goldGrams * 1000).toStringAsFixed(1)} mg',
                  color: const Color(0xFFFBBF24),
                ),
              ),
              Expanded(
                child: _buildMetalStat(
                  metal: 'Silver (Ag)',
                  amount:
                      '${(_valuation.preciousMetals.silverGrams * 1000).toStringAsFixed(0)} mg',
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              Expanded(
                child: _buildMetalStat(
                  metal: 'Copper (Cu)',
                  amount:
                      '${_valuation.preciousMetals.copperGrams.toStringAsFixed(0)} g',
                  color: const Color(0xFFFB923C),
                ),
              ),
              Expanded(
                child: _buildMetalStat(
                  metal: 'CO₂ Saved',
                  amount: '${_valuation.carbonSavedKg} kg',
                  color: const Color(0xFF34D399),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetalStat({
    required String metal,
    required String amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          metal,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
