import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_widgets_app/utils/themes.dart';
import 'package:mobile_widgets_app/widgets/custom_button.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppThemes.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('should render text correctly', (tester) async {
      await tester.pumpWidget(_wrap(CustomButton(text: 'Зберегти', onPressed: () {})));

      expect(find.text('Зберегти'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(CustomButton(text: 'Ok', onPressed: () => pressed++)),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(pressed, 1);
    });

    testWidgets('should show loading state and ignore taps', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(CustomButton(text: 'Ok', isLoading: true, onPressed: () => pressed++)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Ok'), findsNothing);

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(pressed, 0);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(const CustomButton(text: 'Ok')));

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should render icon when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CustomButton(
            text: 'Ok',
            icon: const Icon(Icons.save),
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('outline style uses OutlinedButton, others FilledButton',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          CustomButton(
            text: 'Ok',
            style: CustomButtonStyle.outline,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);

      for (final style in [
        CustomButtonStyle.primary,
        CustomButtonStyle.secondary,
        CustomButtonStyle.danger,
      ]) {
        await tester.pumpWidget(
          _wrap(CustomButton(text: 'Ok', style: style, onPressed: () {})),
        );
        expect(find.byType(FilledButton), findsOneWidget, reason: '$style');
      }
    });
  });
}
