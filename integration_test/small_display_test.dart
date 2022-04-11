import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:converterpro/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Small display test', () {
    testWidgets('Perform conversion, clear and undo', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      var tffFeet = find.byKey(const ValueKey('LENGTH.feet')).evaluate().single.widget as TextFormField;
      var tffInches = find.byKey(const ValueKey('LENGTH.inches')).evaluate().single.widget as TextFormField;
      var tffMeters = find.byKey(const ValueKey('LENGTH.meters')).evaluate().single.widget as TextFormField;

      expect(find.text('Length'), findsOneWidget, reason: 'Expected the length page');

      await tester.enterText(find.byKey(const ValueKey('LENGTH.feet')), '1');
      await tester.pumpAndSettle();

      expect(tffInches.controller!.text, '12', reason: 'Conversion error');
      expect(tffMeters.controller!.text, '0.3048', reason: 'Conversion error');

      await tester.tap(find.byKey(const ValueKey('clearAll')));
      await tester.pumpAndSettle();
      expect(tffFeet.controller!.text, '', reason: 'Text not cleared');
      expect(tffInches.controller!.text, '', reason: 'Text not cleared');
      expect(tffMeters.controller!.text, '', reason: 'Text not cleared');

      await tester.tap(find.byKey(const ValueKey('undoClearAll')));
      await tester.pumpAndSettle();
      expect(tffFeet.controller!.text, '1.0', reason: 'Text not restored');
      expect(tffInches.controller!.text, '12.0', reason: 'Text not restored');
      expect(tffMeters.controller!.text, '0.3048', reason: 'Text not restored');
    });

    testWidgets('Change to a new property and perform conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('menuDrawer')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('drawerItem_currencies')));
      await tester.pumpAndSettle();
      expect(find.text('Currencies'), findsOneWidget, reason: 'Expected the currencies page');
      await tester.tap(find.byKey(const ValueKey('menuDrawer')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('drawerItem_area')));
      await tester.pumpAndSettle();
      expect(find.text('Area'), findsOneWidget, reason: 'Expected the area page');

      var tffInches = find.byKey(const ValueKey('AREA.squareInches')).evaluate().single.widget as TextFormField;
      var tffCentimeters =
          find.byKey(const ValueKey('AREA.squareCentimeters')).evaluate().single.widget as TextFormField;
      var tffMeters = find.byKey(const ValueKey('AREA.squareMeters')).evaluate().single.widget as TextFormField;

      await tester.enterText(find.byKey(const ValueKey('AREA.squareInches')), '1');
      await tester.pumpAndSettle();

      expect(tffCentimeters.controller!.text, '6.4516', reason: 'Conversion error');
      expect(tffMeters.controller!.text, '0.00064516', reason: 'Conversion error');

      await tester.tap(find.byKey(const ValueKey('clearAll')));
      await tester.pumpAndSettle();
      expect(tffInches.controller!.text, '', reason: 'Text not cleared');
      expect(tffCentimeters.controller!.text, '', reason: 'Text not cleared');
      expect(tffMeters.controller!.text, '', reason: 'Text not cleared');
    });

    testWidgets('Change language', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('menuDrawer')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('drawerItem_settings')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('language')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Italiano'));
      await tester.pumpAndSettle();

      await swipeOpenDrawer(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lunghezza'));
      await tester.pumpAndSettle();

      expect(find.text('Lunghezza'), findsOneWidget, reason: 'Expected translated string');
    });

    testWidgets('Check if language has been saved and go back to english', (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle();
      expect(find.text('Lunghezza'), findsOneWidget, reason: 'Expected translated string');

      await tester.tap(find.byKey(const ValueKey('menuDrawer')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('drawerItem_settings')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('language')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
    });

    testWidgets('Reorder units', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // At the beginning the ordering is Meters, Centimeters, Inches, ...
      expect(
        tester.getCenter(find.text('Meters')).dy < tester.getCenter(find.text('Centimeters')).dy &&
            tester.getCenter(find.text('Centimeters')).dy < tester.getCenter(find.text('Inches')).dy,
        true,
        reason: 'Initial ordering of length units is not what expected',
      );

      await tester.tap(find.byKey(const ValueKey('menuDrawer')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('drawerItem_settings')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('reorder-units')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Length'));
      await tester.pumpAndSettle();

      await longPressDrag(
        tester,
        tester.getCenter(find.text('Meters')),
        tester.getCenter(find.text('Feet')),
      );
      await tester.pumpAndSettle();

      await longPressDrag(
        tester,
        tester.getCenter(find.text('Inches')),
        tester.getCenter(find.text('Centimeters')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('confirm')));
      await tester.pumpAndSettle();

      await swipeOpenDrawer(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Length'));
      await tester.pumpAndSettle();

      // Now the ordering should be Inches, Centimeters, Meters, ...
      expect(
        tester.getCenter(find.text('Meters')).dy > tester.getCenter(find.text('Centimeters')).dy &&
            tester.getCenter(find.text('Centimeters')).dy > tester.getCenter(find.text('Inches')).dy,
        true,
        reason: 'Final ordering of length units is not what expected',
      );
    });

    testWidgets('Check if units ordering has been saved', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(find.text('Meters')).dy > tester.getCenter(find.text('Centimeters')).dy &&
            tester.getCenter(find.text('Centimeters')).dy > tester.getCenter(find.text('Inches')).dy,
        true,
        reason: 'Final ordering of length units is not what expected',
      );
    });

    testWidgets('Reorder properties', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('menuDrawer')));
      await tester.pumpAndSettle();

      // At the beginning the ordering is Length, Area, Volume, ...
      expect(
        tester.getCenter(find.byKey(const ValueKey('drawerItem_length'))).dy <
                tester.getCenter(find.byKey(const ValueKey('drawerItem_area'))).dy &&
            tester.getCenter(find.byKey(const ValueKey('drawerItem_area'))).dy <
                tester.getCenter(find.byKey(const ValueKey('drawerItem_volume'))).dy,
        true,
        reason: 'Initial ordering of properties is not what expected',
      );

      await tester.tap(find.byKey(const ValueKey('drawerItem_settings')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('reorder-properties')));
      await tester.pumpAndSettle();

      await longPressDrag(
        tester,
        tester.getCenter(find.text('Length')),
        tester.getCenter(find.text('Currencies')),
      );
      await tester.pumpAndSettle();

      await longPressDrag(
        tester,
        tester.getCenter(find.text('Volume')),
        tester.getCenter(find.text('Area')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('confirm')));
      await tester.pumpAndSettle();

      await swipeOpenDrawer(tester);
      await tester.pumpAndSettle();

      // Now the ordering should be Volume, Area, Length, ...
      expect(
        tester.getCenter(find.byKey(const ValueKey('drawerItem_length'))).dy >
                tester.getCenter(find.byKey(const ValueKey('drawerItem_area'))).dy &&
            tester.getCenter(find.byKey(const ValueKey('drawerItem_area'))).dy >
                tester.getCenter(find.byKey(const ValueKey('drawerItem_volume'))).dy,
        true,
        reason: 'Final ordering the of properties is not what expected',
      );
      //await Future.delayed(const Duration(seconds: 4), () {});
    });

    testWidgets('Check if properties ordering has been saved', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await swipeOpenDrawer(tester);
      await tester.pumpAndSettle();

      expect(
        tester.getCenter(find.byKey(const ValueKey('drawerItem_length'))).dy >
                tester.getCenter(find.byKey(const ValueKey('drawerItem_area'))).dy &&
            tester.getCenter(find.byKey(const ValueKey('drawerItem_area'))).dy >
                tester.getCenter(find.byKey(const ValueKey('drawerItem_volume'))).dy,
        true,
        reason: 'Ordering of the properties is not what expected',
      );
    });

    testWidgets('Simple calculator operations', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('calculator')));
      await tester.pumpAndSettle();

      String? getResultText() => (find.byKey(const ValueKey('result')).evaluate().single.widget as SelectableText).data;

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      
      expect(getResultText(), '3');

      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('6'));
      await tester.pumpAndSettle();
      expect(getResultText(), '6');

      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      expect(getResultText(), '18');

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      expect(getResultText(), '1');
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      expect(getResultText(), '10');

      await tester.tap(find.text('='));
      await tester.pumpAndSettle();
      expect(getResultText(), '28');

    });

  });
}

/// Perform a long press drag from [start] to [end]. Useful for reorderable list
Future<void> longPressDrag(WidgetTester tester, Offset start, Offset end) async {
  final TestGesture drag = await tester.startGesture(start);
  await tester.pump(kLongPressTimeout + kPressTimeout);
  await drag.moveTo(end);
  await tester.pump(kPressTimeout);
  await drag.up();
}

/// Perform a swipe from left to right that opens the drawer (if any)
Future<void> swipeOpenDrawer(WidgetTester tester) async => await tester.dragFrom(
      tester.getTopLeft(find.byType(MaterialApp)),
      const Offset(300, 0),
    );
