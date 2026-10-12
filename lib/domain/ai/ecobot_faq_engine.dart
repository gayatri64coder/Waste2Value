import '../models/chat_message.dart';

class FaqTopic {
  final String id;
  final String title;
  final List<String> triggerKeywords;
  final String answer;
  final List<String> followUpQuestions;

  const FaqTopic({
    required this.id,
    required this.title,
    required this.triggerKeywords,
    required this.answer,
    required this.followUpQuestions,
  });
}

/// Offline, zero-cost intelligent FAQ and advice chatbot for e-waste disposal.
class EcobotFaqEngine {
  EcobotFaqEngine._();

  static const List<FaqTopic> topics = [
    FaqTopic(
      id: 'data_wipe',
      title: 'How do I wipe my data before recycling?',
      triggerKeywords: [
        'wipe',
        'data',
        'privacy',
        'reset',
        'factory reset',
        'delete',
        'icloud',
        'google account',
        'format',
        'personal'
      ],
      answer:
          '🔐 Data Sanitization Steps Before Handover:\n\n'
          '1. **Apple iOS (iPhone/iPad):** Go to Settings > General > Transfer or Reset > Erase All Content and Settings. Ensure you log out of Apple ID / iCloud first so Activation Lock is removed.\n\n'
          '2. **Android:** Go to Settings > System > Reset options > Erase all data (Factory Reset). Remove your Google Account first to avoid Factory Reset Protection (FRP) lock.\n\n'
          '3. **Windows PC / Laptop:** Use Settings > System > Recovery > Reset this PC > Remove everything. Select "Fully clean the drive". For sensitive SSDs, use a DoD 5220.22-M sanitization utility or BitLocker wipe.\n\n'
          '4. **Mac (macOS):** Use System Settings > General > Transfer or Reset > Erase All Content and Settings (Apple Silicon) or Disk Utility erase in macOS Recovery.\n\n'
          '💡 *Certified R2 recyclers in our network also perform certified physical degaussing and shredding if requested.*',
      followUpQuestions: [
        'What are R2 and e-Stewards certifications?',
        'Can I recycle a device with a dead screen?',
        'How does doorstep pickup work?',
      ],
    ),
    FaqTopic(
      id: 'swollen_battery',
      title: 'My battery is swollen or leaking, what do I do?',
      triggerKeywords: [
        'battery',
        'swollen',
        'bulge',
        'leak',
        'fire',
        'hot',
        'smoke',
        'lithium',
        'puff',
        'hazard',
        'danger'
      ],
      answer:
          '🚨 URGENT SAFETY PROTOCOL FOR SWOLLEN BATTERIES:\n\n'
          '1. **DO NOT charge or power on** the device.\n'
          '2. **DO NOT puncture, bend, or squeeze** the battery casing. Puncturing lithium-ion cells can cause violent thermal runaway and toxic gas release.\n'
          '3. **Place the device in a non-flammable container**, such as a metal bucket lined with dry sand or a fire-safe LiPo battery pouch.\n'
          '4. **Keep away from moisture, heat, and flammable materials**.\n'
          '5. **Select "Hazardous / Swollen Battery"** in our Valuation Calculator and request an urgent hazardous drop-off at an R2 certified station.',
      followUpQuestions: [
        'Find nearest hazardous waste drop-off',
        'What toxic materials are inside e-waste?',
        'Schedule a specialized pickup',
      ],
    ),
    FaqTopic(
      id: 'precious_metals',
      title: 'What precious metals are recovered from e-waste?',
      triggerKeywords: [
        'gold',
        'silver',
        'copper',
        'palladium',
        'precious',
        'metals',
        'mineral',
        'mining',
        'smelting',
        'value'
      ],
      answer:
          '✨ Precious Metals in Electronic Waste:\n\n'
          '• **Gold (Au):** 1 metric ton of smartphones yields ~350g of Gold (compared to only 5g per ton from raw rock ore!).\n'
          '• **Silver (Ag):** Essential for high-conductivity solder and contact points (~0.3g per mobile).\n'
          '• **Copper (Cu):** Printed circuit boards (PCBs) contain ~15g per smartphone and up to 800g per desktop PC.\n'
          '• **Palladium (Pd):** Used in ceramic capacitors and hybrid circuits.\n\n'
          '🌱 *Urban mining through waste2value prevents 80% more greenhouse gas emissions than virgin open-pit mining!*',
      followUpQuestions: [
        'How does the valuation calculator estimate value?',
        'What are green credits?',
        'How do I wipe my data?',
      ],
    ),
    FaqTopic(
      id: 'toxic_materials',
      title: 'Why is e-waste dangerous in regular trash?',
      triggerKeywords: [
        'toxic',
        'lead',
        'mercury',
        'cadmium',
        'poison',
        'landfill',
        'danger',
        'harm',
        'environment',
        'pollution'
      ],
      answer:
          '☠️ Hazardous Contaminants in E-Waste:\n\n'
          '• **Lead (Pb):** Found in legacy CRT monitors and solder; damages nervous systems and groundwater.\n'
          '• **Mercury (Hg):** Present in older fluorescent display backlights and switches; bioaccumulates in food chains.\n'
          '• **Cadmium (Cd):** Found in rechargeable NiCd batteries and contact coatings; known carcinogen.\n'
          '• **Brominated Flame Retardants (BFRs):** Emits toxic dioxins when incinerated in informal scrap burning.\n\n'
          '🛡️ *Proper recycling through waste2value guarantees 100% compliant zero-landfill diversion.*',
      followUpQuestions: [
        'What is an ESG recycling certificate?',
        'My battery is swollen, what do I do?',
        'Find nearest certified drop-off hub',
      ],
    ),
    FaqTopic(
      id: 'certifications',
      title: 'What are R2 and e-Stewards certifications?',
      triggerKeywords: [
        'r2',
        'estewards',
        'e-stewards',
        'certified',
        'license',
        'weee',
        'standards',
        'accredited',
        'compliance'
      ],
      answer:
          '🏅 Industry Gold Standards for Recyclers:\n\n'
          '• **R2v3 (Responsible Recycling):** Global standard overseen by SERI requiring strict worker safety, zero toxic export to developing nations, and chain-of-custody tracking.\n'
          '• **e-Stewards:** Rigorous environmental standard prohibiting disposal of toxic e-waste in municipal landfills, incinerators, or prison labor.\n'
          '• **WEEE Compliance:** European Waste Electrical and Electronic Equipment directive adherence.\n\n'
          'All collection centers in waste2value display verified R2/e-Stewards badges.',
      followUpQuestions: [
        'How do I view certified collection centers?',
        'How do I wipe my data before recycling?',
        'What is an ESG recycling certificate?',
      ],
    ),
    FaqTopic(
      id: 'pickup_process',
      title: 'How does doorstep pickup work?',
      triggerKeywords: [
        'pickup',
        'doorstep',
        'schedule',
        'home pickup',
        'collect',
        'transit',
        'book',
        'timing',
        'slot'
      ],
      answer:
          '🚚 Easy 4-Step Doorstep Pickup:\n\n'
          '1. **List Your Item:** Use our Valuation Calculator to evaluate condition and estimate credit value.\n'
          '2. **Schedule a Slot:** Pick your preferred date and time window (Morning 10AM-1PM or Afternoon 2PM-6PM).\n'
          '3. **Handover to Agent:** Our verified collection agent arrives with an antistatic container, inspects your device, and scans your QR code.\n'
          '4. **Earn Green Credits:** Once weighed at the regional hub, Green Credits and your digital Recycling Certificate are deposited into your account.',
      followUpQuestions: [
        'How do I earn and redeem Green Credits?',
        'What are the accepted device categories?',
        'How do I wipe my data before recycling?',
      ],
    ),
    FaqTopic(
      id: 'green_credits',
      title: 'What are Green Credits and how do I redeem them?',
      triggerKeywords: [
        'credit',
        'points',
        'reward',
        'redeem',
        'voucher',
        'cash',
        'money',
        'discount',
        'coupon',
        'perks'
      ],
      answer:
          '🌿 Green Credits & Eco Incentives:\n\n'
          '• Every recycled device earns credits based on weight, carbon saved, and reusable parts.\n'
          '• **Redemption Options:**\n'
          '  - Electronics brand discount coupons (Apple, Samsung, Dell partner stores)\n'
          '  - Direct UPI / Bank payout for working refurbishment-grade devices\n'
          '  - Tree-planting contributions via verified reforestation partners\n'
          '  - ESG sustainability badges for corporate ESG reports',
      followUpQuestions: [
        'How is my device valued?',
        'How do I generate a Recycling Certificate?',
        'How does doorstep pickup work?',
      ],
    ),
    FaqTopic(
      id: 'certificate',
      title: 'What is the digital Recycling Certificate?',
      triggerKeywords: [
        'certificate',
        'esg',
        'proof',
        'audit',
        'corporate',
        'business',
        'carbon certificate',
        'verification',
        'tax'
      ],
      answer:
          '📜 Verified Green Disposal Certificate:\n\n'
          '• Generated upon certified destruction and recycling completion at an R2 facility.\n'
          '• Includes: Cryptographic verification hash, total kg e-waste diverted, CO₂ equivalent emissions avoided, and certifying facility registration number.\n'
          '• Recognized for ESG corporate sustainability audits and tax incentive filings.',
      followUpQuestions: [
        'What are R2 and e-Stewards certifications?',
        'How do I schedule a pickup?',
        'What precious metals are recovered?',
      ],
    ),
  ];

  /// Processes user question and returns a matched answer with follow-up chips.
  static ChatMessage answerQuery(String userQuery) {
    final lower = userQuery.toLowerCase().trim();

    FaqTopic? bestMatch;
    int highestScore = 0;

    for (final topic in topics) {
      int score = 0;
      for (final kw in topic.triggerKeywords) {
        if (lower.contains(kw)) {
          score += (kw.contains(' ') ? 4 : 2);
        }
      }
      if (score > highestScore) {
        highestScore = score;
        bestMatch = topic;
      }
    }

    if (bestMatch != null && highestScore >= 2) {
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: MessageSender.bot,
        text: bestMatch.answer,
        timestamp: DateTime.now(),
        suggestions: bestMatch.followUpQuestions,
        topicTag: bestMatch.id,
      );
    }

    // Default friendly fallback with key discovery topics
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.bot,
      text:
          'Hello! I am **EcoBot**, your offline e-waste advisor. 🤖🌱\n\n'
          'I can assist you with data sanitization, device valuation, battery safety, certified drop-off hubs, and doorstep pickups.\n\n'
          'Select a topic below or type your question:',
      timestamp: DateTime.now(),
      suggestions: const [
        'How do I wipe my data before recycling?',
        'My battery is swollen or leaking, what do I do?',
        'What precious metals are recovered from e-waste?',
        'How does doorstep pickup work?',
        'What are R2 and e-Stewards certifications?',
      ],
      topicTag: 'general',
    );
  }
}
