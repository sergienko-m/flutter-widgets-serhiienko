import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_widgets_app/models/user.dart';
import 'package:mobile_widgets_app/utils/themes.dart';
import 'package:mobile_widgets_app/widgets/custom_button.dart';
import 'package:mobile_widgets_app/widgets/profile_widget.dart';

const _user = User(
  id: '1',
  name: 'Олександр Шевченко',
  email: 'oleksandr@example.com',
);

Widget _wrap(Widget child, {double width = 800}) => MaterialApp(
      theme: AppThemes.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width, child: child),
        ),
      ),
    );

void main() {
  group('ProfileWidget', () {
    testWidgets('shows name, email and initials', (tester) async {
      await tester.pumpWidget(_wrap(const ProfileWidget(user: _user)));

      expect(find.text('Олександр Шевченко'), findsOneWidget);
      expect(find.text('oleksandr@example.com'), findsOneWidget);
      expect(find.text('ОШ'), findsOneWidget);
    });

    testWidgets('expanded mode shows CustomButton and handles tap',
        (tester) async {
      var edits = 0;
      await tester.pumpWidget(
        _wrap(ProfileWidget(user: _user, onEditPressed: () => edits++)),
      );

      expect(find.byType(CustomButton), findsOneWidget);
      await tester.tap(find.byKey(const Key('profile_edit_button')));
      await tester.pump();

      expect(edits, 1);
    });

    testWidgets('compact mode shows icon button instead of CustomButton',
        (tester) async {
      var edits = 0;
      await tester.pumpWidget(
        _wrap(
          ProfileWidget(
            user: _user,
            isCompact: true,
            onEditPressed: () => edits++,
          ),
        ),
      );

      expect(find.byType(CustomButton), findsNothing);
      await tester.tap(find.byKey(const Key('profile_edit_button')));
      await tester.pump();

      expect(edits, 1);
    });

    testWidgets('hides edit button when callback is null', (tester) async {
      await tester.pumpWidget(_wrap(const ProfileWidget(user: _user)));

      expect(find.byKey(const Key('profile_edit_button')), findsNothing);
    });

    testWidgets('is responsive: renders on a narrow screen without errors',
        (tester) async {
      await tester.pumpWidget(
        _wrap(ProfileWidget(user: _user, onEditPressed: () {}), width: 320),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Олександр Шевченко'), findsOneWidget);
    });
  });
}
