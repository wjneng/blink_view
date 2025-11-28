## 简介
一个轻量级的 Flutter 组件，用于实现子组件的透明度闪烁动画效果，支持自定义闪烁间隔、透明度范围和动画曲线。

## 特性
* ✨ 自定义闪烁间隔时间
* 🎨 可配置最小 / 最大透明度
* 🚀 支持自定义动画曲线
* 🔌 可动态启用 / 禁用闪烁效果
* 📱 适配所有 Flutter 支持的平台


## 基本使用

```dart
import 'package:blink_view/blink_view.dart';

BlinkView(
    child: const Text('我在闪烁'),
),
```