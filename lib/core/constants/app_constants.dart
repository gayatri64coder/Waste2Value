/// Application constants and SDG target definitions for Waste2Value
class AppConstants {
  AppConstants._();

  static const String appName = 'Waste2Value';
  static const String appTagline = 'Responsible E-Waste Management & Circular Valuation';
  static const String appVersion = '1.0.0';

  // SDG Definitions supported by Waste2Value
  static const Map<String, SdgGoal> sdgGoals = {
    '12': SdgGoal(
      number: '12',
      title: 'Responsible Consumption & Production',
      code: 'SDG 12',
      colorHex: 0xFFBF8B2E,
      description: 'Promote resource and energy efficiency, sustainable infrastructure, and reduce electronic waste.',
    ),
    '11': SdgGoal(
      number: '11',
      title: 'Sustainable Cities & Communities',
      code: 'SDG 11',
      colorHex: 0xFFFD9D24,
      description: 'Make urban settlements inclusive, safe, resilient, and free from toxic landfill pollution.',
    ),
    '13': SdgGoal(
      number: '13',
      title: 'Climate Action',
      code: 'SDG 13',
      colorHex: 0xFF3F7E44,
      description: 'Take urgent action to combat climate change and its impacts through embodied carbon abatement.',
    ),
    '8': SdgGoal(
      number: '8',
      title: 'Decent Work & Economic Growth',
      code: 'SDG 8',
      colorHex: 0xFFA21942,
      description: 'Support certified, formal green jobs in electronic refurbishment and safe hydrometallurgical recycling.',
    ),
  };

  // Default initial demo metrics
  static const double defaultCo2SavedPerKg = 2.45; // kg CO2e saved per kg of e-waste recycled
  static const double defaultTreesPer100KgCo2 = 4.8;
  static const int defaultCreditsPerDollarValue = 2;
}

class SdgGoal {
  final String number;
  final String title;
  final String code;
  final int colorHex;
  final String description;

  const SdgGoal({
    required this.number,
    required this.title,
    required this.code,
    required this.colorHex,
    required this.description,
  });
}
