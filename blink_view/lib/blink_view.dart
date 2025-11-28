import 'package:flutter/material.dart';

class BlinkView extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 闪烁动画时长（单次往返的总时长），默认1秒
  final Duration duration;

  /// 是否启用闪烁，默认为true
  final bool enabled;

  /// 透明度变化曲线，默认为Curves.easeInOut
  final Curve curve;

  /// 最小透明度，默认为0.3
  final double minOpacity;

  /// 最大透明度，默认为1.0
  final double maxOpacity;

  /// 每次闪烁完成（往返一次）的回调
  final VoidCallback? onBlinkComplete;

  const BlinkView({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 1),
    this.enabled = true,
    this.curve = Curves.easeInOut,
    this.minOpacity = 0.3,
    this.maxOpacity = 1.0,
    this.onBlinkComplete,
  })  : assert(minOpacity >= 0.0 && minOpacity <= 1.0,
            'minOpacity 必须在 0.0 ~ 1.0 之间'),
        assert(maxOpacity >= 0.0 && maxOpacity <= 1.0,
            'maxOpacity 必须在 0.0 ~ 1.0 之间'),
        assert(minOpacity < maxOpacity, 'minOpacity 必须小于 maxOpacity');

  @override
  State<BlinkView> createState() => _BlinkViewState();
}

class _BlinkViewState extends State<BlinkView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器（时长为单次单向动画，往返总时长 = duration）
    _controller = AnimationController(
      duration: widget.duration ~/ 2,
      vsync: this,
    );

    // 初始化透明度动画
    _initAnimation();

    // 监听动画状态，触发完成回调
    _controller.addStatusListener(_handleAnimationStatus);

    // 启用时开始闪烁
    if (widget.enabled) {
      _startBlinking();
    }
  }

  @override
  void didUpdateWidget(BlinkView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 处理动画时长变更
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration ~/ 2;
    }

    // 处理启用状态变更
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _startBlinking();
      } else {
        _stopBlinking();
      }
    }

    // 处理透明度/曲线参数变更
    if (oldWidget.curve != widget.curve ||
        oldWidget.minOpacity != widget.minOpacity ||
        oldWidget.maxOpacity != widget.maxOpacity) {
      _initAnimation();
      // 触发重建，让AnimatedBuilder感知动画参数变化
      if (mounted) setState(() {});
    }
  }

  /// 初始化/重置透明度动画
  void _initAnimation() {
    _animation = Tween<double>(
      begin: widget.maxOpacity,
      end: widget.minOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  /// 处理动画状态回调
  void _handleAnimationStatus(AnimationStatus status) {
    // 往返动画完成一次时触发回调
    if (status == AnimationStatus.dismissed && widget.onBlinkComplete != null) {
      widget.onBlinkComplete!();
    }
  }

  /// 开始闪烁动画
  void _startBlinking() {
    if (!mounted) return;
    // reverse=true：动画会在 forward 和 reverse 之间循环
    _controller.repeat(reverse: true);
  }

  /// 停止闪烁并平滑恢复到最大透明度
  void _stopBlinking() {
    if (!mounted) return;
    _controller.stop();
    // 平滑过渡到不透明状态
    _controller.animateTo(
      0.0, // 对应maxOpacity
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          // 禁用时固定为最大透明度，启用时使用动画值
          opacity: widget.enabled ? _animation.value : widget.maxOpacity,
          child: widget.child,
        );
      },
    );
  }
}
