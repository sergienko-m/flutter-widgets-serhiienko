import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_widgets_app/utils/themes.dart';
import 'package:mobile_widgets_app/widgets/animated_counter.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppThemes.light,
      home: Scaffold(body: Center(child: child)),
    );

String _value(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('counter_value'))).data!;

void main() {
  group('AnimatedCounter', () {
    testWidgets('starts from initialValue', (tester) async {
      await tester.pumpWidget(
        _wrap(const AnimatedCounter(initialValue: 3, maxValue: 10)),
      );

      expect(_value(tester), '3');
    });

    testWidgets('increments and decrements', (tester) async {
      await tester.pumpWidget(_wrap(const AnimatedCounter(maxValue: 5)));

      await tester.tap(find.byKey(const Key('counter_increment')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('counter_increment')));
      await tester.pumpAndSettle();
      expect(_value(tester), '2');

      await tester.tap(find.byKey(const Key('counter_decrement')));
      await tester.pumpAndSettle();
      expect(_value(tester), '1');
    });

    testWidgets('decrement is disabled at zero', (tester) async {
      await tester.pumpWidget(_wrap(const AnimatedCounter(maxValue: 5)));

      final button = tester.widget<IconButton>(
        find.byKey(const Key('counter_decrement')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('stops at maxValue, turns success color, progress is full',
        (tester) async {
      await tester.pumpWidget(_wrap(const AnimatedCounter(maxValue: 2)));

      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const Key('counter_increment')));
        await tester.pumpAndSettle();
      }

      final increment = tester.widget<IconButton>(
        find.byKey(const Key('counter_increment')),
      );
      expect(increment.onPressed, isNull);
      expect(_value(tester), '2');

      final text = tester.widget<Text>(find.byKey(const Key('counter_value')));
      expect(text.style?.color, AppStyle.light.success);

      final progress = tester.widget<LinearProgressIndicator>(
        find.byKey(const Key('counter_progress')),
      );
      expect(progress.value, 1.0);
    });

    testWidgets('reset returns to initialValue and onChanged fires',
        (tester) async {
      final changes = <int>[];
      await tester.pumpWidget(
        _wrap(AnimatedCounter(maxValue: 5, onChanged: changes.add)),
      );

      await tester.tap(find.byKey(const Key('counter_increment')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('counter_reset')));
      await tester.pumpAndSettle();

      expect(_value(tester), '0');
      expect(changes, [1, 0]);
    });

    testWidgets('clamps value when maxValue is reduced (didUpdateWidget)',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const AnimatedCounter(initialValue: 5, maxValue: 10)),
      );
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('counter_increment')));
        await tester.pumpAndSettle();
      }
      expect(_value(tester), '8');

      // той самий State, нові параметри -> didUpdateWidget
      await tester.pumpWidget(
        _wrap(const AnimatedCounter(initialValue: 5, maxValue: 6)),
      );
      await tester.pumpAndSettle();

      expect(_value(tester), '6');
    });
  });
}
