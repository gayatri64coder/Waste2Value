import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waste2value/domain/ai/device_inspection_classifier.dart';
import 'package:waste2value/domain/ai/ecobot_faq_engine.dart';
import 'package:waste2value/domain/ai/ewaste_valuation_engine.dart';
import 'package:waste2value/domain/models/ewaste_item.dart';
import 'package:waste2value/main.dart';

void main() {
  group('EwasteValuationEngine Unit Tests', () {
    test('Calculates valuation and precious metals for smartphone', () {
      final result = EwasteValuationEngine.evaluate(
        category: DeviceCategory.smartphone,
        brand: 'Apple',
        purchaseYear: 2021,
        condition: DeviceCondition.good,
        functionalStatus: FunctionalStatus.working,
      );

      expect(result.estimatedValue, greaterThan(20.0));
      expect(result.carbonSavedKg, greaterThan(10.0));
      expect(result.preciousMetals.goldGrams, greaterThan(0.0));
      expect(result.preciousMetals.copperGrams, greaterThan(5.0));
      expect(result.greenCredits, greaterThan(20));
      expect(result.requiresHazardousHandling, isFalse);
    });

    test('Swollen battery triggers hazardous containment alert', () {
      final result = EwasteValuationEngine.evaluate(
        category: DeviceCategory.battery,
        brand: 'Generic',
        purchaseYear: 2020,
        condition: DeviceCondition.brokenOrDamaged,
        functionalStatus: FunctionalStatus.hazardousBattery,
      );

      expect(result.requiresHazardousHandling, isTrue);
      expect(result.hazardLevel, contains('High'));
      expect(result.actionableInsights.first, contains('Swollen'));
    });
  });

  group('DeviceInspectionClassifier Unit Tests', () {
    test('Identifies flawless working device with high confidence', () {
      final report = DeviceInspectionClassifier.evaluateChecks(
        checkResults: {
          'powers_on': true,
          'screen_intact': true,
          'battery_flat': true,
          'ports_working': true,
          'data_wiped': true,
        },
        hasSwollenBatteryReported: false,
      );

      expect(report.confidenceScore, greaterThanOrEqualTo(90));
      expect(report.determinedCondition, equals(DeviceCondition.flawless));
      expect(report.determinedFunctionalStatus, equals(FunctionalStatus.working));
    });

    test('Detects battery swelling hazard', () {
      final report = DeviceInspectionClassifier.evaluateChecks(
        checkResults: {
          'powers_on': true,
          'screen_intact': true,
          'battery_flat': false,
          'ports_working': true,
          'data_wiped': false,
        },
        hasSwollenBatteryReported: true,
      );

      expect(report.determinedFunctionalStatus,
          equals(FunctionalStatus.hazardousBattery));
      expect(report.safetyAdvisory, contains('SAFETY ADVISORY'));
    });
  });

  group('EcobotFaqEngine Unit Tests', () {
    test('Answers data wiping queries accurately', () {
      final reply = EcobotFaqEngine.answerQuery('How do I wipe my data and iCloud?');
      expect(reply.text, contains('Data Sanitization Steps'));
      expect(reply.text, contains('Apple ID'));
      expect(reply.suggestions.length, greaterThan(0));
    });

    test('Answers swollen battery query with emergency instructions', () {
      final reply = EcobotFaqEngine.answerQuery('My phone battery is swollen and hot');
      expect(reply.text, contains('SAFETY PROTOCOL'));
      expect(reply.text, contains('DO NOT charge'));
    });

    test('Answers precious metals query', () {
      final reply = EcobotFaqEngine.answerQuery('What precious metals are recovered?');
      expect(reply.text, contains('Gold (Au)'));
      expect(reply.text, contains('Silver (Ag)'));
    });
  });

  group('App Smoke Test', () {
    testWidgets('Renders Waste2ValueApp root navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(const Waste2ValueApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Dashboard'), findsWidgets);
    });
  });
}
