import 'package:flutter/cupertino.dart'
    show
        CupertinoActivityIndicator,
        CupertinoAlertDialog,
        CupertinoButton,
        CupertinoDialogAction,
        CupertinoSlider,
        CupertinoSwitch,
        showCupertinoDialog;
import 'package:flutter/material.dart';

import '../utils/app_state.dart';
import '../utils/constants.dart';
import '../widgets/animated_counter.dart';
import '../widgets/custom_button.dart';
import '../widgets/profile_widget.dart';

/// Showcase / Component Library Demo.
///
/// Усі кастомні віджети з інтерактивними контролами для зміни параметрів,
/// а також демонстрація layout-віджетів, Cupertino-компонентів, діалогів
/// та lifecycle-методів. Приклади коду — у розкривних блоках "Код".
class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  CustomButtonStyle _style = CustomButtonStyle.primary;
  bool _loading = false;
  bool _withIcon = true;
  bool _compact = false;
  double _max = 10;
  bool _iosSwitch = false;
  double _iosSlider = 0.4;

  bool _showProbe = true;
  int _tick = 0;
  final List<String> _lifecycleLog = [];

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1200),
        ),
      );
  }

  void _logLifecycle(String event) {
    debugPrint('[lifecycle] $event');
    _lifecycleLog.insert(0, event);
    if (_lifecycleLog.length > 6) _lifecycleLog.removeLast();
    // setState не можна викликати під час build/mount — відкладаємо
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final user = app.currentUser ?? kDemoUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: 'CustomButton — StatelessWidget',
          code: _buttonCode,
          child: _buildButtons(),
        ),
        _Section(
          title: 'ProfileWidget — StatelessWidget',
          code: _profileCode,
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('isCompact'),
                value: _compact,
                onChanged: (v) => setState(() => _compact = v),
              ),
              ProfileWidget(
                user: user,
                isCompact: _compact,
                onEditPressed: () => _snack('Редагування профілю'),
              ),
            ],
          ),
        ),
        _Section(
          title: 'AnimatedCounter — StatefulWidget + анімації',
          code: _counterCode,
          child: Column(
            children: [
              Row(
                children: [
                  Text('maxValue: ${_max.round()}'),
                  Expanded(
                    child: Slider(
                      value: _max,
                      min: 5,
                      max: 50,
                      divisions: 9,
                      label: _max.round().toString(),
                      onChanged: (v) => setState(() => _max = v),
                    ),
                  ),
                ],
              ),
              AnimatedCounter(maxValue: _max.round()),
            ],
          ),
        ),
        _Section(
          title: 'Layout: Container, Row, Column, Stack, Positioned',
          code: _layoutCode,
          child: _buildLayoutDemo(context),
        ),
        _Section(
          title: 'Material і Cupertino (iOS-style) компоненти',
          code: _cupertinoCode,
          child: _buildCupertinoDemo(),
        ),
        _Section(
          title: 'Lifecycle методів State',
          code: _lifecycleCode,
          child: _buildLifecycleDemo(),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in CustomButtonStyle.values)
              CustomButton(
                text: s.name,
                style: s,
                onPressed: () => _snack('Натиснуто: ${s.name}'),
              ),
          ],
        ),
        const Divider(height: 24),
        const Text('Інтерактивні параметри'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final s in CustomButtonStyle.values)
              ChoiceChip(
                label: Text(s.name),
                selected: _style == s,
                onSelected: (_) => setState(() => _style = s),
              ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('isLoading'),
          value: _loading,
          onChanged: (v) => setState(() => _loading = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('icon'),
          value: _withIcon,
          onChanged: (v) => setState(() => _withIcon = v),
        ),
        CustomButton(
          text: 'Інтерактивна кнопка',
          style: _style,
          isLoading: _loading,
          icon: _withIcon ? const Icon(Icons.save_outlined, size: 18) : null,
          onPressed: () => _snack('Збережено (${_style.name})'),
        ),
      ],
    );
  }

  Widget _buildLayoutDemo(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Positioned(
            left: 16,
            top: 14,
            child: Text(
              'Positioned: top-left',
              style: TextStyle(color: scheme.onPrimaryContainer),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 14,
            child: Row(
              children: [
                Icon(Icons.layers, color: scheme.onPrimaryContainer),
                const SizedBox(width: 6),
                Text(
                  'Row: bottom-right',
                  style: TextStyle(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
          Align(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Column', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Container',
                    style: TextStyle(color: scheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMaterialDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити елемент?'),
        content: const Text('Material-діалог.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }

  void _showCupertinoDialog() {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Видалити елемент?'),
        content: const Text('Діалог у стилі iOS.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Скасувати'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }

  Widget _buildCupertinoDemo() {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton(
          onPressed: _showMaterialDialog,
          child: const Text('Material dialog'),
        ),
        CupertinoButton.filled(
          onPressed: _showCupertinoDialog,
          child: const Text('Cupertino dialog'),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Material'),
            Switch(
              value: _iosSwitch,
              onChanged: (v) => setState(() => _iosSwitch = v),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cupertino'),
            const SizedBox(width: 8),
            CupertinoSwitch(
              value: _iosSwitch,
              onChanged: (v) => setState(() => _iosSwitch = v),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // індикатор крутиться лише коли перемикач увімкнено
            CupertinoActivityIndicator(animating: _iosSwitch),
            const SizedBox(width: 8),
            const Text('ActivityIndicator'),
          ],
        ),
        SizedBox(
          width: 220,
          child: CupertinoSlider(
            value: _iosSlider,
            onChanged: (v) => setState(() => _iosSlider = v),
          ),
        ),
      ],
    );
  }

  Widget _buildLifecycleDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Змонтувати віджет (initState / dispose)'),
          value: _showProbe,
          onChanged: (v) => setState(() => _showProbe = v),
        ),
        Row(
          children: [
            if (_showProbe)
              _LifecycleProbe(value: _tick, onEvent: _logLifecycle)
            else
              const Text('Віджет видалено з дерева'),
            const Spacer(),
            CustomButton(
              text: 'value + 1',
              style: CustomButtonStyle.secondary,
              onPressed: () => setState(() => _tick++),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final line in _lifecycleLog)
          Text('• $line', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  // ---- code samples (показуються у розкривних блоках) ----
  static const _buttonCode = r'''
CustomButton(
  text: 'Зберегти',
  style: CustomButtonStyle.primary, // secondary | danger | outline
  icon: Icon(Icons.save_outlined, size: 18),
  isLoading: false,
  onPressed: () {},
)''';

  static const _profileCode = r'''
ProfileWidget(
  user: user,
  isCompact: false,
  onEditPressed: () => showDialog(...),
)''';

  static const _counterCode = r'''
AnimatedCounter(
  initialValue: 0,
  maxValue: 20,
  animationDuration: Duration(milliseconds: 300),
  primaryColor: Colors.indigo,
)''';

  static const _layoutCode = r'''
Stack(children: [
  Container(decoration: BoxDecoration(...)),
  Positioned(left: 16, top: 14, child: Text('...')),
  Positioned(right: 16, bottom: 14, child: Row(...)),
  Align(child: Column(mainAxisSize: MainAxisSize.min, ...)),
])''';

  static const _cupertinoCode = r'''
showCupertinoDialog(
  context: context,
  builder: (ctx) => CupertinoAlertDialog(
    title: Text('...'),
    actions: [CupertinoDialogAction(child: Text('OK'), onPressed: ...)],
  ),
);
CupertinoSwitch(value: v, onChanged: (v) => setState(...));''';

  static const _lifecycleCode = r'''
initState()              // 1 раз: створити контролери, підписки
didChangeDependencies()  // після initState і при зміні InheritedWidget
didUpdateWidget(old)     // батько передав нові параметри
build()                  // може викликатись багато разів — без побічних ефектів
deactivate() / dispose() // звільнити контролери, таймери, підписки''';
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.code});

  final String title;
  final Widget child;
  final String? code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
            if (code != null)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Код'),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SelectableText(
                      code!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Віджет, що логує свої lifecycle-події через [onEvent].
class _LifecycleProbe extends StatefulWidget {
  const _LifecycleProbe({required this.value, required this.onEvent});

  final int value;
  final ValueChanged<String> onEvent;

  @override
  State<_LifecycleProbe> createState() => _LifecycleProbeState();
}

class _LifecycleProbeState extends State<_LifecycleProbe> {
  @override
  void initState() {
    super.initState();
    widget.onEvent('initState (value = ${widget.value})');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onEvent('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant _LifecycleProbe oldWidget) {
    super.didUpdateWidget(oldWidget);
    // логуємо лише реальну зміну, інакше вийде цикл setState -> rebuild -> log
    if (oldWidget.value != widget.value) {
      widget.onEvent('didUpdateWidget (${oldWidget.value} → ${widget.value})');
    }
  }

  @override
  void dispose() {
    widget.onEvent('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('value = ${widget.value}'));
  }
}
