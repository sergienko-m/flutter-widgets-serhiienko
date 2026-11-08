import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/themes.dart';
import 'bounce_tap.dart';

/// Анімований лічильник (StatefulWidget).
///
/// Анімації:
///  * scale — число "підстрибує" при кожній зміні (AnimationController + TweenSequence);
///  * color — при досягненні [maxValue] колір плавно змінюється на "успіх";
///  * bounce — кнопки пружинять при натисканні ([BounceTap]);
///  * progress — індикатор прогресу плавно рухається (TweenAnimationBuilder).
///
/// Lifecycle: initState (створення контролера), didUpdateWidget (реакція на нові
/// параметри), dispose (звільнення контролера).
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    this.initialValue = 0,
    this.maxValue = 100,
    this.animationDuration = const Duration(milliseconds: 300),
    this.primaryColor,
    this.onChanged,
  })  : assert(maxValue > 0),
        assert(initialValue >= 0 && initialValue <= maxValue);

  final int initialValue;
  final int maxValue;
  final Duration animationDuration;
  final Color? primaryColor;
  final ValueChanged<int>? onChanged;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with TickerProviderStateMixin {
  late int _value;
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    // якщо максимум зменшили нижче поточного значення — підтискаємо його
    if (_value > widget.maxValue) {
      _value = widget.maxValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _change(int delta) {
    final next = math.max(0, math.min(widget.maxValue, _value + delta));
    if (next == _value) return;
    setState(() => _value = next);
    _controller.forward(from: 0);
    widget.onChanged?.call(next);
  }

  void _reset() {
    if (_value == widget.initialValue) return;
    setState(() => _value = widget.initialValue);
    _controller.forward(from: 0);
    widget.onChanged?.call(_value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = widget.primaryColor ?? theme.colorScheme.primary;
    final atMax = _value >= widget.maxValue;
    final target = atMax ? AppStyle.of(context).success : base;
    final progress = _value / widget.maxValue;

    return Semantics(
      label: 'Лічильник',
      value: '$_value з ${widget.maxValue}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: target),
                duration: widget.animationDuration,
                builder: (context, color, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _scale,
                        child: Text(
                          '$_value',
                          key: const Key('counter_value'),
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: progress),
                        duration: widget.animationDuration * 2,
                        curve: Curves.easeInOut,
                        builder: (context, value, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              key: const Key('counter_progress'),
                              value: value,
                              minHeight: 10,
                              color: color,
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                '$_value / ${widget.maxValue}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  BounceTap(
                    child: IconButton.filledTonal(
                      key: const Key('counter_decrement'),
                      tooltip: 'Зменшити',
                      onPressed: _value > 0 ? () => _change(-1) : null,
                      icon: const Icon(Icons.remove),
                    ),
                  ),
                  BounceTap(
                    child: IconButton.filled(
                      key: const Key('counter_increment'),
                      tooltip: 'Збільшити',
                      onPressed: atMax ? null : () => _change(1),
                      icon: const Icon(Icons.add),
                    ),
                  ),
                  TextButton(
                    key: const Key('counter_reset'),
                    onPressed: _reset,
                    child: const Text('Скинути'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
