import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'utils/app_state.dart';
import 'utils/constants.dart';
import 'utils/themes.dart';

void main() => runApp(const MyApp());

/// Корінь застосунку: MyApp -> AppScope -> MaterialApp -> HomeScreen.
class MyApp extends StatefulWidget {
  const MyApp({super.key, this.state});

  /// Для тестів можна передати власний [AppState].
  final AppState? state;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppState _state;
  late final bool _ownsState;

  @override
  void initState() {
    super.initState();
    _ownsState = widget.state == null;
    _state = widget.state ?? AppState(user: kDemoUser);
  }

  @override
  void dispose() {
    if (_ownsState) _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      // MaterialApp перебудовується лише для зміни themeMode
      child: ListenableBuilder(
        listenable: _state,
        builder: (context, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: _state.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
