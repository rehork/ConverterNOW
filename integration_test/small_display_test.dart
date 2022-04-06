import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:converterpro/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smartphone test', () {
    testWidgets('Perform conversion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      var tffInches = find.byKey(const ValueKey('LENGTH.inches')).evaluate().single.widget as TextFormField;
      var tffCentimeters = find.byKey(const ValueKey('LENGTH.centimeters')).evaluate().single.widget as TextFormField;
      var tffMeters = find.byKey(const ValueKey('LENGTH.meters')).evaluate().single.widget as TextFormField;

      expect(find.text('Length'), findsOneWidget, reason: 'Expected the length page');

      await tester.enterText(find.byKey(const ValueKey('LENGTH.inches')), '1');
      await tester.pumpAndSettle();

      expect(tffCentimeters.controller!.text, '2.54', reason: 'Conversion error');
      expect(tffMeters.controller!.text, '0.0254', reason: 'Conversion error');
      
      await tester.tap(find.byKey(const ValueKey('clearAll')));
      await tester.pumpAndSettle();
      expect(tffInches.controller!.text, '', reason: 'Text not cleared');
      expect(tffCentimeters.controller!.text, '', reason: 'Text not cleared');
      expect(tffMeters.controller!.text, '', reason: 'Text not cleared');
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
      var tffCentimeters = find.byKey(const ValueKey('AREA.squareCentimeters')).evaluate().single.widget as TextFormField;
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
      
      //await Future.delayed(const Duration(seconds: 2), (){});
    });
  });
}