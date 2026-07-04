import 'package:book_reader_app/helpers/consts.dart';
import 'package:flutter/material.dart';

/// Wraps [child] with a subtle scale-down on press, giving instant tactile
/// feedback (emil-design-eng: pressable elements must feel responsive).
///
/// Respects reduced-motion — when the platform disables animations the scale
/// effect is skipped but the tap still works.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = pressScale,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final target = (_pressed && !reduceMotion) ? widget.scale : 1.0;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: target,
        duration: pressFeedbackDuration,
        curve: easeOutStrong,
        child: widget.child,
      ),
    );
  }
}
