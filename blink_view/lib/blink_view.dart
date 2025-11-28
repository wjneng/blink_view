import 'dart:async';
import 'package:flutter/material.dart';

/// 闪烁组件
///
/// 使用示例：
/// ```dart
/// BlinkView(
///   child: _customView(),
///   interval: Duration(milliseconds: 500),
///   minOpacity: 0.2,
///   maxOpacity: 1.0,
/// )
/// ```
class BlinkView extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 闪烁间隔时间，默认1秒
  final Duration interval;

  /// 是否启用闪烁，默认为true
  final bool enabled;

  /// 透明度变化曲线，默认为Curves.easeInOut
  final Curve curve;

  /// 最小透明度，默认为0.3
  final double minOpacity;

  /// 最大透明度，默认为1.0
  final double maxOpacity;

  const BlinkView(
      {super.key,
      required this.child,
      this.interval = const Duration(seconds: 1),
      this.enabled = true,
      this.curve = Curves.easeInOut,
      this.minOpacity = 0.3,
      this.maxOpacity = 1.0})
      : assert(minOpacity >= 0.0 && minOpacity <= 1.0,
            'minOpacity must be between 0.0 and 1.0'),
        assert(maxOpacity >= 0.0 && maxOpacity <= 1.0,
            'maxOpacity must be between 0.0 and 1.0'),
        assert(
            minOpacity < maxOpacity, 'minOpacity must be less than maxOpacity');

  @override
  State<BlinkView> createState() => _BlinkViewState();
}

class _BlinkViewState extends State<BlinkView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.interval, vsync: this);

    _animation = Tween<double>(begin: widget.maxOpacity, end: widget.minOpacity)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.enabled) {
      _startBlinking();
    }
  }

  @override
  void didUpdateWidget(BlinkView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.interval != widget.interval) {
      _controller.duration = widget.interval;
    }

    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _startBlinking();
      } else {
        _stopBlinking();
      }
    }

    if (oldWidget.curve != widget.curve ||
        oldWidget.minOpacity != widget.minOpacity ||
        oldWidget.maxOpacity != widget.maxOpacity) {
      _animation = Tween<double>(
              begin: widget.maxOpacity, end: widget.minOpacity)
          .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    }
  }

  void _startBlinking() {
    _timer = Timer.periodic(widget.interval, (timer) {
      if (mounted) {
        _controller.forward().then((_) {
          if (mounted) {
            _controller.reverse();
          }
        });
      }
    });
  }

  void _stopBlinking() {
    _timer?.cancel();
    _timer = null;
    _controller.reset();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
            opacity: widget.enabled ? _animation.value : 1.0,
            child: widget.child);
      },
    );
  }
}
