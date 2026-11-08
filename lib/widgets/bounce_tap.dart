import 'package:flutter/material.dart';

/// Додає "пружинний" ефект натискання будь-якому віджету.
/// Listener не перехоплює жести, тому вкладена кнопка працює як зазвичай.
class BounceTap extends StatefulWidget {
  const BounceTap({super.key, required this.child, this.scaleDown = 0.9});

  final Widget child;
  final double scaleDown;

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1.0,
        duration: Duration(milliseconds: _pressed ? 90 : 450),
        // elasticOut дає "відскок" при відпусканні
        curve: _pressed ? Curves.easeOut : Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}
